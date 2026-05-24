# fwb::fwb(...) =>
#
# local({
#   .progressr_steps <- R
#   .progressr_simple <- if (is.null(simple)) wtype != "multinom" else simple
#   .progressr_skip_count <- if (.progressr_simple) 2L else 1L
#   .progressr_progressor <- progressr::progressor(steps = .progressr_steps)
#   fwb::fwb(
#     data = x,
#     statistic = function(..., ...FUN, .progressr_progressor) {
#       if (.progressr_skip_count > 0L) {
#         .progressr_skip_count <<- .progressr_skip_count - 1L
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
progressify_fwb <- local({
  template_fwb_outer <- bquote_compile(local({
    .progressr_steps <- .(STEPS)
    .progressr_simple <- if (is.null(.(SIMPLE))) .(WTYPE) != "multinom" else .(SIMPLE)
    .progressr_skip_count <- if (.progressr_simple) 2L else 1L
    .progressr_progressor <- progressr::progressor(steps = .progressr_steps)
    .(EXPR)
  }))

  template_fwb_FUN <- bquote_compile(function(..., ...FUN, .progressr_progressor) {
    if (.progressr_skip_count > 0L) {
      .progressr_skip_count <<- .progressr_skip_count - 1L
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
    idx_simple <- which(names == "simple")
    idx_wtype <- which(names == "wtype")

    parts <- as.list(expr)

    steps <- if (length(idx_R) == 1L) parts[[idx_R]] else 999L
    parts[[idx_R]] <- quote(.progressr_steps)

    simple_expr <- if (length(idx_simple) == 1L) parts[[idx_simple]] else quote(NULL)
    wtype_expr <- if (length(idx_wtype) == 1L) parts[[idx_wtype]] else quote(getOption("fwb_wtype", "exp"))

    stopifnot(length(idx_statistic) == 1L)
    statistic <- expr[[idx_statistic]]
    parts[[idx_statistic]] <- bquote_apply(template_fwb_FUN, FUN = statistic)

    idx_verbose <- which(names == "verbose")
    if (length(idx_verbose) == 0L) {
      parts$verbose <- FALSE
    }

    progressr_args <- list(
      ...FUN = statistic,
      .progressr_progressor = quote(.progressr_progressor)
    )
    parts <- c(parts, progressr_args)

    bquote_apply(template_fwb_outer, STEPS = steps, SIMPLE = simple_expr, WTYPE = wtype_expr, EXPR = as.call(parts))
  } ## progressify_fwb()
})


append_builtin_transpilers_for_fwb <- local({
  known_fcns <- list(
    fwb = c
  )

  template <- bquote_compile(function(expr, options) {
    ns <- getNamespace("fwb")
    fcn <- get(.(fcn_name), mode = "function", envir = ns)
    progressify_fwb(expr, fcn_name = .(fcn_name), fcn = fcn, envir = parent.frame())
  })

  make_transpiler <- function(fcn_name) {
    transpiler <- eval(bquote_apply(template))
    eval(transpiler)
  }

  function() {
    ## fwb::fwb()
    transpilers <- list()
    for (fcn_name in names(known_fcns)) {
      transpilers[[fcn_name]] <- list(
        label = sprintf("fwb::%s() transpiler", fcn_name),
        transpiler = make_transpiler(fcn_name)
      )
    } ## for (fcn_name ...)
    transpilers <- list(fwb = transpilers)

    append_transpilers("progressify::built-in", transpilers)

    ## Return required packages
    c("fwb", "progressr")
  }
})
