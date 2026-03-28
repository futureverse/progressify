# foreach(x = xs, .combine = c) %dofuture% { sqrt(x) } =>
#
# local({
#   .progressr_progressor <- progressr::progressor(along = xs)
#   foreach(x = xs, .combine = c) %dofuture% {
#     on.exit(.progressr_progressor())
#     sqrt(x)
#   }
# })
#
append_builtin_transpilers_for_doFuture <- local({
  known_fcns <- list(
    `%dofuture%` = c
  )

  template <- bquote_compile(function(expr, options) {
    ns <- getNamespace("doFuture")
    fcn <- get(.(fcn_name), mode = "function", envir = ns)
    progressify_foreach(expr, fcn_name = .(fcn_name), fcn = fcn, envir = parent.frame())
  })

  make_transpiler <- function(fcn_name) {
    transpiler <- eval(bquote_apply(template))
    eval(transpiler)
  }

  function() {
    ## doFuture::`%dofuture%`()
    transpilers <- list()
    for (fcn_name in names(known_fcns)) {
      transpilers[[fcn_name]] <- list(
        label = sprintf("doFuture::`%s` transpiler", fcn_name),
        transpiler = make_transpiler(fcn_name)
      )
    } ## for (fcn_name ...)
    transpilers <- list(doFuture = transpilers)

    append_transpilers("progressify::built-in", transpilers)

    ## Return required packages
    c("doFuture", "progressr")
  }
})
