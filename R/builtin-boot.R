# boot::boot(...) =>
#
# local({
#   .progressr_steps <- R
#   .progressr_first <- TRUE
#   .progressr_progressor <- progressr::progressor(steps = .progressr_steps)
#   boot::boot(
#     data = x,
#     statistic = function(..., ...FUN, .progressr_progressor) {
#       if (.progressr_first) {
#         .progressr_first <<- FALSE
#       } else {
#         on.exit(.progressr_progressor())
#       }
#       ...FUN(...)
#     },
#     R = .progressr_steps,
#     ...FUN = statistic,
#     .progressr_progressor = .progressr_progressor
#   )
# })
#
progressify_boot <- local({
  template_boot_outer <- bquote_compile(local({
    .progressr_steps <- .(STEPS)
    .progressr_first <- TRUE
    .progressr_progressor <- progressr::progressor(steps = .progressr_steps)
    .(EXPR)
  }))

  template_boot_FUN <- bquote_compile(function(..., ...FUN, .progressr_progressor) {
    if (.progressr_first) {
      .progressr_first <<- FALSE
    } else {
      on.exit(.progressr_progressor())
    }
    ...FUN(...)
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

    idx_R <- which(names == "R")
    idx_statistic <- which(names == "statistic")

    parts <- as.list(expr)

    stopifnot(length(idx_R) == 1L)
    steps <- parts[[idx_R]]
    parts[[idx_R]] <- quote(.progressr_steps)

    stopifnot(length(idx_statistic) == 1L)
    statistic <- expr[[idx_statistic]]
    parts[[idx_statistic]] <- bquote_apply(template_boot_FUN, FUN = statistic)

    progressr_args <- list(
      ...FUN = statistic,
      .progressr_progressor = quote(.progressr_progressor)
    )
    parts <- c(parts, progressr_args)

    bquote_apply(template_boot_outer, STEPS = steps, EXPR = as.call(parts))
  } ## progressify_boot()
})


append_builtin_transpilers_for_boot <- local({
  known_fcns <- list(
    boot = c,
    censboot = c,
    tsboot = c
  )

  template <- bquote_compile(function(expr, options) {
    ns <- getNamespace("boot")
    fcn <- get(.(fcn_name), mode = "function", envir = ns)
    progressify_boot(expr, fcn_name = .(fcn_name), fcn = fcn, envir = parent.frame())
  })

  make_transpiler <- function(fcn_name) {
    transpiler <- eval(bquote_apply(template))
    eval(transpiler)
  }

  function() {
    ## boot::boot(), boot::censboot(), boot::tsboot()
    transpilers <- list()
    for (fcn_name in names(known_fcns)) {
      transpilers[[fcn_name]] <- list(
        label = sprintf("boot::%s() transpiler", fcn_name),
        transpiler = make_transpiler(fcn_name)
      )
    } ## for (fcn_name ...)
    transpilers <- list(boot = transpilers)

    append_transpilers("progressify::built-in", transpilers)

    ## Return required packages
    c("boot", "progressr")
  }
})
