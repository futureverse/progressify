# car::Boot(object, f = coef, labels = names(f(object)), R = 999, ...) =>
#
# local({
#   .progressr_steps <- R
#   ## Boot() calls f(object) once before bootstrapping, plus once more
#   ## if 'labels' is not specified, and boot::boot() calls it once for
#   ## the original data, before the R bootstrap replicates
#   .progressr_skip <- 3L
#   .progressr_progressor <- progressr::progressor(steps = .progressr_steps)
#   .progressr_f <- f
#   car::Boot(
#     object = object,
#     f = function(...) {
#       if (.progressr_skip > 0L) {
#         .progressr_skip <<- .progressr_skip - 1L
#       } else {
#         on.exit(.progressr_progressor())
#       }
#       .progressr_f(...)
#     },
#     R = .progressr_steps
#   )
# })
#
# Note that a bootstrap replicate for which the refitted model is rank
# deficient does not call 'f', and therefore does not signal progress.
#
progressify_car <- local({
  template_Boot_outer <- bquote_compile(local({
    .progressr_steps <- .(STEPS)
    .progressr_skip <- .(SKIP)
    .progressr_progressor <- progressr::progressor(steps = .progressr_steps)
    .progressr_f <- .(FUN)
    .(EXPR)
  }))

  template_Boot_f <- quote(function(...) {
    if (.progressr_skip > 0L) {
      .progressr_skip <<- .progressr_skip - 1L
    } else {
      on.exit(.progressr_progressor())
    }
    .progressr_f(...)
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

    parts <- as.list(expr)
    names(parts) <- names

    idx_f <- which(names == "f")
    if (length(idx_f) == 1L) {
      FUN <- parts[[idx_f]]
    } else {
      FUN <- quote(stats::coef)
    }
    parts[["f"]] <- template_Boot_f

    ## Calls to f() before the bootstrap replicates
    skip <- 2L
    if (!"labels" %in% names) skip <- skip + 1L

    idx_R <- which(names == "R")
    if (length(idx_R) == 1L) {
      steps <- parts[[idx_R]]
    } else {
      steps <- formals(fcn)[["R"]]
    }
    parts[["R"]] <- quote(.progressr_steps)

    bquote_apply(template_Boot_outer, STEPS = steps, SKIP = skip, FUN = FUN, EXPR = as.call(parts))
  } ## progressify_car()
})


append_builtin_transpilers_for_car <- local({
  ## Boot() is an S3 generic function. All of its methods ('default',
  ## 'lm', 'glm', and 'nls') have the same arguments and call 'f' the
  ## same number of times
  known_fcns <- list(
    Boot = c
  )

  template <- bquote_compile(function(expr, options) {
    ns <- getNamespace("car")
    fcn <- get(.(fcn_name), mode = "function", envir = ns)
    progressify_car(expr, fcn_name = .(fcn_name), fcn = fcn, envir = parent.frame())
  })

  make_transpiler <- function(fcn_name) {
    transpiler <- eval(bquote_apply(template))
    eval(transpiler)
  }

  function() {
    ## car::Boot()
    transpilers <- list()
    for (fcn_name in names(known_fcns)) {
      transpilers[[fcn_name]] <- list(
        label = sprintf("car::%s() transpiler", fcn_name),
        transpiler = make_transpiler(fcn_name)
      )
    } ## for (fcn_name ...)
    transpilers <- list(car = transpilers)

    append_transpilers("progressify::built-in", transpilers)

    ## Return required packages
    c("car", "progressr")
  }
})
