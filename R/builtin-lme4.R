# lme4::bootMer(...) =>
#
# local({
#   .progressr_steps <- nsim
#   .progressr_first <- TRUE
#   .progressr_progressor <- progressr::progressor(steps = .progressr_steps)
#   .progressr_FUN <- FUN
#   lme4::bootMer(
#     x = x,
#     FUN = function(...) {
#       if (.progressr_first) {
#         .progressr_first <<- FALSE
#       } else {
#         on.exit(.progressr_progressor())
#       }
#       .progressr_FUN(...)
#     },
#     nsim = .progressr_steps
#   )
# })
#
progressify_lme4 <- local({
  template_bootMer_outer <- bquote_compile(local({
    .progressr_steps <- .(STEPS)
    .progressr_first <- TRUE
    .progressr_progressor <- progressr::progressor(steps = .progressr_steps)
    .progressr_FUN <- .(FUN)
    .(EXPR)
  }))

  template_bootMer_FUN <- quote(function(...) {
    if (.progressr_first) {
      .progressr_first <<- FALSE
    } else {
      on.exit(.progressr_progressor())
    }
    .progressr_FUN(...)
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

    idx_nsim <- which(names == "nsim")
    idx_FUN <- which(names == "FUN")

    parts <- as.list(expr)

    if (length(idx_nsim) == 1L) {
      steps <- parts[[idx_nsim]]
      parts[[idx_nsim]] <- quote(.progressr_steps)
    } else {
      steps <- 1L
      parts$nsim <- quote(.progressr_steps)
    }

    stopifnot(length(idx_FUN) == 1L)
    FUN <- expr[[idx_FUN]]
    parts[[idx_FUN]] <- template_bootMer_FUN

    bquote_apply(template_bootMer_outer, STEPS = steps, FUN = FUN, EXPR = as.call(parts))
  } ## progressify_lme4()
})


append_builtin_transpilers_for_lme4 <- local({
  known_fcns <- list(
    bootMer = c
  )

  template <- bquote_compile(function(expr, options) {
    ns <- getNamespace("lme4")
    fcn <- get(.(fcn_name), mode = "function", envir = ns)
    progressify_lme4(expr, fcn_name = .(fcn_name), fcn = fcn, envir = parent.frame())
  })

  make_transpiler <- function(fcn_name) {
    transpiler <- eval(bquote_apply(template))
    eval(transpiler)
  }

  function() {
    ## lme4::bootMer()
    transpilers <- list()
    for (fcn_name in names(known_fcns)) {
      transpilers[[fcn_name]] <- list(
        label = sprintf("lme4::%s() transpiler", fcn_name),
        transpiler = make_transpiler(fcn_name)
      )
    } ## for (fcn_name ...)
    transpilers <- list(lme4 = transpilers)

    append_transpilers("progressify::built-in", transpilers)

    ## Return required packages
    c("lme4", "progressr")
  }
})
