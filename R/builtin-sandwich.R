progressify_sandwich <- local({
  function(expr, fcn_name, fcn, ..., envir = parent.frame()) {
    parts <- as.list(expr)
    parts$applyfun <- quote(function(X, FUN, ...) {
      lapply(X = X, FUN = FUN, ...) |> progressify::progressify()
    })
    as.call(parts)
  }
})


append_builtin_transpilers_for_sandwich <- local({
  known_fcns <- list(
    vcovBS = c,
    vcovJK = c
  )

  template <- bquote_compile(function(expr, options) {
    ns <- getNamespace("sandwich")
    fcn <- get(.(fcn_name), mode = "function", envir = ns)
    progressify_sandwich(expr, fcn_name = .(fcn_name), fcn = fcn, envir = parent.frame())
  })

  make_transpiler <- function(fcn_name) {
    transpiler <- eval(bquote_apply(template))
    eval(transpiler)
  }

  function() {
    ## sandwich::vcovBS(), sandwich::vcovJK()
    transpilers <- list()
    for (fcn_name in names(known_fcns)) {
      transpilers[[fcn_name]] <- list(
        label = sprintf("sandwich::%s() transpiler", fcn_name),
        transpiler = make_transpiler(fcn_name)
      )
    } ## for (fcn_name ...)
    transpilers <- list(sandwich = transpilers)

    append_transpilers("progressify::built-in", transpilers)

    ## Return required packages
    c("sandwich", "progressr")
  }
})
