# foreach(x = xs, .combine = c) %do% { sqrt(x) } =>
#
# local({
#   .progressr_progressor <- progressr::progressor(along = xs)
#   foreach(x = xs, .combine = c) %do% {
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

    ## Find the first iteration argument in the foreach() call.
    ## Iteration arguments are passed via ... and do NOT start with "."
    foreach_names <- names(foreach_call)
    if (is.null(foreach_names)) foreach_names <- rep("", length(foreach_call))
    iter_idxs <- which(nzchar(foreach_names) & !startsWith(foreach_names, "."))
    stopifnot(length(iter_idxs) >= 1L)

    ## Use the first iteration argument to determine progress steps
    iter_expr <- foreach_call[[iter_idxs[1]]]

    ## Wrap body with on.exit() progress signal
    parts <- as.list(expr)
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
