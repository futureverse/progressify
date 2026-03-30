# stats::dendrapply(X = d, FUN = FUN, ...) =>
#
# local(
#   stats::dendrapply(X = {
#       .progressr_progressor <- progressr::progressor(
#         steps = 2L * attr(d, "members") - 1L)
#       d
#     }, FUN = function(..., .progressr_progressor) {
#       on.exit(.progressr_progressor())
#       FUN(...)
#     }, .progressr_progressor = .progressr_progressor)
# )
#
progressify_stats <- local({
  ## Pre-compiled bquote templates
  template_steps_dendro <- bquote_compile({
    .progressr_progressor <- progressr::progressor(
      steps = 2L * attr(.(DATA), "members") - 1L)
    .(DATA)
  })

  template_FUN <- bquote_compile(function(..., .progressr_progressor) {
    on.exit(.progressr_progressor())
    .(FUN)(...)
  })

  function(expr, fcn_name, fcn, ..., envir = parent.frame()) {
    names <- names(expr)
    if (is.null(names)) names <- rep("", length.out = length(expr))
    names <- names[-1]
    target_names <- names(formals(fcn))[seq_along(names)]
    unnamed <- setdiff(target_names, names)
    ## Handle '...' in formals - only resolve positional args before it
    ddd <- which(unnamed == "...")
    if (length(ddd) > 0L) {
      stopifnot(length(ddd) == 1L)
      unnamed <- unnamed[seq_len(ddd - 1L)]
    }
    empty_idxs <- which(names == "")
    n <- min(length(empty_idxs), length(unnamed))
    if (n > 0L) names[empty_idxs[seq_len(n)]] <- unnamed[seq_len(n)]
    names <- c("", names)

    if (fcn_name == "dendrapply") {
      idx_X <- which(names == "X")
      idx_FUN <- which(names == "FUN")

      parts <- as.list(expr)

      stopifnot(length(idx_X) == 1L)
      parts[[idx_X]] <- bquote_apply(template_steps_dendro, DATA = parts[[idx_X]])

      stopifnot(length(idx_FUN) == 1L)
      FUN <- expr[[idx_FUN]]
      parts[[idx_FUN]] <- bquote_apply(template_FUN, FUN = FUN)

      progressr_args <- list(
        .progressr_progressor = quote(.progressr_progressor)
      )
      parts <- c(parts, progressr_args)

      bquote(local(.(as.call(parts))))
    }
  } ## progressify_stats()
})


append_builtin_transpilers_for_stats <- local({
  known_fcns <- list(
    dendrapply = c
  )

  template <- bquote_compile(function(expr, options) {
    ns <- getNamespace("stats")
    fcn <- get(.(fcn_name), mode = "function", envir = ns)
    progressify_stats(expr, fcn_name = .(fcn_name), fcn = fcn, envir = parent.frame())
  })

  make_transpiler <- function(fcn_name) {
    transpiler <- eval(bquote_apply(template))
    eval(transpiler)
  }

  function() {
    ## stats::dendrapply()
    transpilers <- list()
    for (fcn_name in names(known_fcns)) {
      transpilers[[fcn_name]] <- list(
        label = sprintf("stats::%s() transpiler", fcn_name),
        transpiler = make_transpiler(fcn_name)
      )
    } ## for (fcn_name ...)
    transpilers <- list(stats = transpilers)

    append_transpilers("progressify::built-in", transpilers)

    ## Return required packages
    c("stats", "progressr")
  }
})
