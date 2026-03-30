# BiocParallel::bplapply(X = xs, FUN = FUN, ...) =>
#
# local(
#   BiocParallel::bplapply(X = {
#       .progressr_progressor <- progressr::progressor(along = xs)
#       xs
#     }, FUN = function(..., .progressr_progressor) {
#       on.exit(.progressr_progressor())
#       FUN(...)
#     }, .progressr_progressor = .progressr_progressor)
# )
#
# BiocParallel::bpmapply(FUN, xs) =>
#
# local({
#   .progressr_progressor <- progressr::progressor(along = xs)
#   BiocParallel::bpmapply(function(...) {
#     on.exit(.progressr_progressor())
#     FUN(...)
#   }, xs)
# })
#
progressify_BiocParallel <- local({
  ## bpmapply():
  ## Argument 'FUN' wrapper that captures '.progressr_progressor' from the
  ## enclosing environment (i.e. not via arguments), because argument '...'
  ## of bpmapply() is used for data, not for passing extra arguments to FUN()
  template_FUN_closure <- bquote_compile(function(...) {
    on.exit(.progressr_progressor())
    .(FUN)(...)
  })

  function(expr, fcn_name, fcn, ..., envir = parent.frame()) {
    names <- names(expr)
    if (is.null(names)) names <- rep("", length.out = length(expr))
    names <- names[-1]
    target_names <- names(formals(fcn))[seq_along(names)]
    unnamed <- setdiff(target_names, names)
    ddd <- which(unnamed == "...")
    if (length(ddd) > 0L) {
      stopifnot(length(ddd) == 1L)
      unnamed <- unnamed[seq_len(ddd - 1L)]
    }
    empty_idxs <- which(names == "")
    n <- min(length(empty_idxs), length(unnamed))
    if (n > 0L) names[empty_idxs[seq_len(n)]] <- unnamed[seq_len(n)]
    names <- c("", names)

    if (fcn_name %in% c("bplapply")) {
      idx_X <- which(names == "X")
      idx_FUN <- which(names == "FUN")

      parts <- as.list(expr)

      stopifnot(length(idx_X) == 1L)
      parts[[idx_X]] <- bquote_apply(template_along, ALONG = parts[[idx_X]])

      stopifnot(length(idx_FUN) == 1L)
      FUN <- expr[[idx_FUN]]
      parts[[idx_FUN]] <- bquote_apply(template_FUN, FUN = FUN)

      progressr_args <- list(
        .progressr_progressor = quote(.progressr_progressor)
      )
      parts <- c(parts, progressr_args)

      bquote(local(.(as.call(parts))))

    } else if (fcn_name %in% c("bpmapply")) {
      idx_FUN <- which(names == "FUN")

      ## First argument in '...' defines the number of iterations
      unnamed_idxs <- which(names == "" & seq_along(names) > 1L)
      stopifnot(length(unnamed_idxs) > 0L)
      idx_dots_first <- unnamed_idxs[1L]

      parts <- as.list(expr)

      stopifnot(length(idx_FUN) == 1L)
      FUN <- expr[[idx_FUN]]
      parts[[idx_FUN]] <- bquote_apply(template_FUN_closure, FUN = FUN)

      along_expr <- parts[[idx_dots_first]]

      bquote_apply(template_outer, ALONG = along_expr, EXPR = as.call(parts))
    }
  } ## progressify_BiocParallel()
})


append_builtin_transpilers_for_BiocParallel <- local({
  known_fcns <- list(
    bplapply = c,
    bpmapply = c
    ## Other BiocParallel functions are much harder to support;
    ## * bpvec():
    ##   FUN is vectorized, i.e. receives chunks, not elements, so
    ##   cannot use 'along = X' or similar
    ## * bpiterate():
    ##   iterates over unknown number of steps
    ## * bpaggregate():
    ##   Arguments 'by', 'FUN' are passed via S4 dispatch through '...',
    ##   an the number of iterations depends on the number of groups
  )

  template <- bquote_compile(function(expr, options) {
    ns <- getNamespace("BiocParallel")
    fcn <- get(.(fcn_name), mode = "function", envir = ns)
    progressify_BiocParallel(expr, fcn_name = .(fcn_name), fcn = fcn, envir = parent.frame())
  })

  make_transpiler <- function(fcn_name) {
    transpiler <- eval(bquote_apply(template))
    eval(transpiler)
  }

  function() {
    ## BiocParallel::bplapply(), ...
    transpilers <- list()
    for (fcn_name in names(known_fcns)) {
      transpilers[[fcn_name]] <- list(
        label = sprintf("BiocParallel::%s() transpiler", fcn_name),
        transpiler = make_transpiler(fcn_name)
      )
    } ## for (fcn_name ...)
    transpilers <- list(BiocParallel = transpilers)

    append_transpilers("progressify::built-in", transpilers)

    ## Return required packages
    c("BiocParallel", "progressr")
  }
})
