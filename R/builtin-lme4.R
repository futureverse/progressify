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


# confint(<merMod>, method = "boot", ...) =>
#
# local({
#   .progressr_steps <- nsim
#   .progressr_progressor <- progressr::progressor(steps = .progressr_steps)
#   ## lme4::bootMer() looks up <.progress>ProgressBar() and
#   ## set<.Progress>ProgressBar() via get(), which falls back to
#   ## the search path
#   base_attach <- base::attach ## silence R CMD check
#   base_attach(list(
#     progressrProgressBar = function(progressor) progressor,
#     setProgressrProgressBar = function(pb, value) pb()
#   ), name = "progressify:lme4", warn.conflicts = FALSE)
#   on.exit(base::detach("progressify:lme4", character.only = TRUE))
#   confint(
#     object = fit,
#     method = "boot",
#     nsim = .progressr_steps,
#     .progress = "progressr",
#     PBargs = list(progressor = .progressr_progressor)
#   )
# })
#
progressify_lme4_confint <- local({
  template_confint_outer <- bquote_compile(local({
    .progressr_steps <- .(STEPS)
    .progressr_progressor <- progressr::progressor(steps = .progressr_steps)
    base_attach <- base::attach ## silence R CMD check
    base_attach(list(
      progressrProgressBar = function(progressor) progressor,
      setProgressrProgressBar = function(pb, value) pb()
    ), name = "progressify:lme4", warn.conflicts = FALSE)
    on.exit(base::detach("progressify:lme4", character.only = TRUE))
    .(EXPR)
  }))

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

    ## Only method = "boot" is supported
    idx_method <- which(names == "method")
    method <- if (length(idx_method) == 1L) expr[[idx_method]] else "profile"
    if (!is.character(method) || length(method) != 1L) {
      stop_with_version(sprintf("Do not know how to progressify %s(), because argument 'method' is not a character string: %s", fcn_name, deparse(method)[1]))
    }
    method <- match.arg(method, choices = eval(formals(fcn)[["method"]]))
    if (tolower(method) != "boot") {
      stop_with_version(sprintf("Do not know how to progressify %s() with method = %s; only method = \"boot\" is supported", fcn_name, dQuote(method, q = FALSE)))
    }

    parts <- as.list(expr)
    names(parts) <- names

    idx_nsim <- which(names == "nsim")
    if (length(idx_nsim) == 1L) {
      steps <- parts[[idx_nsim]]
    } else {
      steps <- formals(fcn)[["nsim"]]
    }
    parts[["nsim"]] <- quote(.progressr_steps)

    ## Replace any progress bar settings with our own
    parts[[".progress"]] <- "progressr"
    parts[["PBargs"]] <- quote(list(progressor = .progressr_progressor))

    bquote_apply(template_confint_outer, STEPS = steps, EXPR = as.call(parts))
  } ## progressify_lme4_confint()
})


append_builtin_transpilers_for_lme4 <- local({
  known_fcns <- list(
    bootMer = quote(progressify_lme4),
    confint.merMod = quote(progressify_lme4_confint)
  )

  template <- bquote_compile(function(expr, options) {
    ns <- getNamespace("lme4")
    fcn <- get(.(fcn_name), mode = "function", envir = ns)
    .(PROGRESSIFY)(expr, fcn_name = .(fcn_name), fcn = fcn, envir = parent.frame())
  })

  make_transpiler <- function(fcn_name) {
    PROGRESSIFY <- known_fcns[[fcn_name]]
    transpiler <- eval(bquote_apply(template))
    eval(transpiler)
  }

  function() {
    ## lme4::bootMer(), confint(<merMod>, method = "boot")
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
