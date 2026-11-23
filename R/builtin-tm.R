# tm::tm_map(<VCorpus>, ...) =>
#
# local({
#   .progressr_tm_engine <- tm::tm_parLapply_engine()
#   on.exit(tm::tm_parLapply_engine(.progressr_tm_engine))
#   tm::tm_parLapply_engine(function(X, FUN, ...) {
#     lapply(X = X, FUN = FUN, ...) |> progressify::progressify()
#   })
#   tm::tm_map(<VCorpus>, ...)
# })
#
# Same for tm::TermDocumentMatrix(), tm::DocumentTermMatrix(), and
# tm::tm_index(), which all call tm::tm_parLapply() internally, which
# in turn calls the registered 'tm_parLapply_engine' function.
#
progressify_tm <- local({
  template <- bquote_compile(local({
    .progressr_tm_engine <- tm::tm_parLapply_engine()
    on.exit(tm::tm_parLapply_engine(.progressr_tm_engine))
    tm::tm_parLapply_engine(function(X, FUN, ...) {
      lapply(X = X, FUN = FUN, ...) |> progressify::progressify()
    })
    .(EXPR)
  }))

  function(expr, fcn_name, fcn, ..., envir = parent.frame()) {
    bquote_apply(template, EXPR = expr)
  }
})


append_builtin_transpilers_for_tm <- local({
  ## Only functions and S3 methods that call tm::tm_parLapply()
  known_fcns <- list(
    tm_map.VCorpus = c,
    TermDocumentMatrix.VCorpus = c,
    TermDocumentMatrix.PCorpus = c,
    DocumentTermMatrix = c,
    tm_index.VCorpus = c,
    tm_index.PCorpus = c,
    tm_index.SimpleCorpus = c
  )

  template <- bquote_compile(function(expr, options) {
    ns <- getNamespace("tm")
    fcn <- get(.(fcn_name), mode = "function", envir = ns)
    progressify_tm(expr, fcn_name = .(fcn_name), fcn = fcn, envir = parent.frame())
  })

  make_transpiler <- function(fcn_name) {
    transpiler <- eval(bquote_apply(template))
    eval(transpiler)
  }

  function() {
    ## tm::tm_map(), tm::TermDocumentMatrix(), tm::DocumentTermMatrix(),
    ## tm::tm_index()
    transpilers <- list()
    for (fcn_name in names(known_fcns)) {
      transpilers[[fcn_name]] <- list(
        label = sprintf("tm::%s() transpiler", fcn_name),
        transpiler = make_transpiler(fcn_name)
      )
    } ## for (fcn_name ...)
    transpilers <- list(tm = transpilers)

    append_transpilers("progressify::built-in", transpilers)

    ## Return required packages
    c("tm", "progressr")
  }
})
