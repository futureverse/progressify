#' Evaluate a regular map-reduce call in parallel
#'
#' @param expr An R expression.
#'
#' @param substitute If TRUE, `expr` is quoted.
#'
#' @param \ldots Not used.
#' 
#' @param when If TRUE (default), the expression is progressified, otherwise not.
#'
#' @param eval If TRUE (default), the progressified expression is evaluated,
#' other it is returned.
#'
#' @param envir The environment in which `expr` is evaluated.
#' 
#' @returns
#' Returns the value of the evaluated expression `expr`.
#'
#' @example incl/progressify-base.R
#'
#' @aliases pz
#' @importFrom progressr progressor
#' @export
progressify <- local({
  transpile <- import_from("transpile", package = "futurize")
  
  function(expr, substitute = TRUE, ..., when = TRUE, eval = TRUE, envir = parent.frame()) {
    if (substitute) expr <- substitute(expr)
    debug <- isTRUE(getOption("progressify.debug"))
    if (debug) {
      mdebug_push("progressify() ...")
      on.exit(mdebug_pop())
    }
  
    transpile(expr, substitute = FALSE, when = when, eval = eval, type = "progressify::built-in", envir = envir, what = "progressify", debug = debug)
  } ## progressify()
})
class(progressify) <- c("transpiler", class(progressify))

#' @export
pz <- progressify
