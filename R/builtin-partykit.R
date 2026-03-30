# partykit::cforest(...) =>
#
# partykit::cforest(..., applyfun = function(...) {
#   lapply(...) |> progressify::progressify()
# })
#
progressify_partykit <- local({
  function(expr, fcn_name, fcn, ..., envir = parent.frame()) {
    parts <- as.list(expr)
    parts$applyfun <- quote(function(X, FUN, ...) {
      lapply(X = X, FUN = FUN, ...) |> progressify::progressify()
    })
    as.call(parts)
  }
})


append_builtin_transpilers_for_partykit <- local({
  known_fcns <- list(
    cforest = c
  )

  template <- bquote_compile(function(expr, options) {
    ns <- getNamespace("partykit")
    fcn <- get(.(fcn_name), mode = "function", envir = ns)
    progressify_partykit(expr, fcn_name = .(fcn_name), fcn = fcn, envir = parent.frame())
  })

  make_transpiler <- function(fcn_name) {
    transpiler <- eval(bquote_apply(template))
    eval(transpiler)
  }

  function() {
    ## partykit::cforest(), ...
    transpilers <- list()
    for (fcn_name in names(known_fcns)) {
      transpilers[[fcn_name]] <- list(
        label = sprintf("partykit::%s() transpiler", fcn_name),
        transpiler = make_transpiler(fcn_name)
      )
    } ## for (fcn_name ...)
    transpilers <- list(partykit = transpilers)

    append_transpilers("progressify::built-in", transpilers)

    ## Return required packages
    c("partykit", "progressr")
  }
})
