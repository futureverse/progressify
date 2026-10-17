# foreach(x = xs, .combine = c) %do% { sqrt(x) } =>
#
# local({
#   .progressr_along <- xs
#   .progressr_progressor <- progressr::progressor(along = .progressr_along)
#   foreach(x = .progressr_along, .combine = c) %do% {
#     on.exit(.progressr_progressor())
#     sqrt(x)
#   }
# })
#
progressify_foreach <- local({
  ## Pre-compiled bquote templates
  template_body <- bquote_compile(local({
    on.exit(.progressr_progressor())
    .(BODY)
  }))

  function(expr, fcn_name, fcn, ..., envir = parent.frame()) {
    ## expr is:  %do%(foreach(...), { body })
    ## expr[[1]] = `%do%`
    ## expr[[2]] = foreach(...) call
    ## expr[[3]] = body expression

    foreach_call <- expr[[2]]

    ## Nested foreach() calls, e.g. foreach(...) %:% foreach(...) or
    ## foreach(...) %:% when(...), are not supported, because the total
    ## number of iterations cannot be inferred upfront
    op <- foreach_call[[1]]
    if (identical(op, as.symbol("%:%")) || identical(op, quote(foreach::`%:%`))) {
      stop(sprintf("Cannot progressify nested foreach() calls using %%:%%: %s", paste(trimws(deparse(expr)), collapse = " ")), call. = FALSE)
    }

    ## Find the first iteration argument in the foreach() call.
    ## Iteration arguments are passed via ... and do NOT start with "."
    foreach_names <- names(foreach_call)
    if (is.null(foreach_names)) foreach_names <- rep("", length(foreach_call))
    iter_idxs <- which(nzchar(foreach_names) & !startsWith(foreach_names, "."))
    stopifnot(length(iter_idxs) >= 1L)

    ## Use the first iteration argument to determine progress steps.
    ## It is evaluated only once, before calling foreach(), which then
    ## iterates over the evaluated value. This cannot be done inside the
    ## foreach() argument itself, because foreach evaluates its arguments
    ## in a temporary environment.
    iter_idx <- iter_idxs[1]
    iter_expr <- foreach_call[[iter_idx]]
    foreach_call[[iter_idx]] <- quote(.progressr_along)

    ## Wrap body with on.exit() progress signal
    parts <- as.list(expr)
    parts[[2]] <- foreach_call
    parts[[3]] <- bquote_apply(template_body, BODY = expr[[3]])

    ## Wrap everything in local() with progressor initialization
    bquote_apply(template_outer, ALONG = iter_expr, EXPR = as.call(parts))
  } ## progressify_foreach()
})


append_builtin_transpilers_for_foreach <- local({
  known_fcns <- list(
    `%do%` = c,
    `%dopar%` = c
  )

  template <- bquote_compile(function(expr, options) {
    ns <- getNamespace("foreach")
    fcn <- get(.(fcn_name), mode = "function", envir = ns)
    progressify_foreach(expr, fcn_name = .(fcn_name), fcn = fcn, envir = parent.frame())
  })

  make_transpiler <- function(fcn_name) {
    transpiler <- eval(bquote_apply(template))
    eval(transpiler)
  }

  function() {
    ## foreach::`%do%`(), ...
    transpilers <- list()
    for (fcn_name in names(known_fcns)) {
      transpilers[[fcn_name]] <- list(
        label = sprintf("foreach::`%s` transpiler", fcn_name),
        transpiler = make_transpiler(fcn_name)
      )
    } ## for (fcn_name ...)
    transpilers <- list(foreach = transpilers)

    append_transpilers("progressify::built-in", transpilers)

    ## Return required packages
    c("foreach", "progressr")
  }
})
