#' Evaluate a regular map-reduce call with progress updates
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
#' otherwise it is returned.
#'
#' @param envir The environment in which `expr` is evaluated.
#' 
#' @returns
#' Returns the value of the evaluated expression `expr`.
#'
#' @section Expression unwrapping:
#' The transpilation mechanism includes logic to "unwrap" expressions
#' enclosed in constructs such as `!`, `{ }`, `( )`, `local()`, `I()`,
#' `identity()`, `invisible()`, `suppressMessages()`, `suppressWarnings()`,
#' `suppressPackageStartupMessages()`, `withCallingHandlers()`, and
#' `with()`. The transpiler descends through wrapping
#' constructs until it finds a transpilable expression, avoiding the
#' need to place `progressify()` inside such constructs. This allows for
#' patterns like:
#'
#' ```r
#' y <- {
#'   lapply(xs, fcn)
#' } |> suppressMessages() |> progressify()
#' ```
#'
#' avoiding having to write:
#'
#' ```r
#' y <- {
#'   lapply(xs, fcn) |> progressify()
#' } |> suppressMessages()
#' ```
#'
#' @example incl/progressify-base.R
#'
#' @aliases pz
#' @importFrom progressr progressor
#' @export
progressify <- function(expr, substitute = TRUE, ..., when = TRUE, eval = TRUE, envir = parent.frame()) {
  if (substitute) expr <- substitute(expr)
  debug <- isDebugEnabled()
  if (debug) {
    mdebug_push("progressify() ...")
    on.exit(mdebug_pop())
  }

  transpile(expr, substitute = FALSE, when = when, eval = eval, type = "progressify::built-in", envir = envir, what = "progressify", debug = debug)
} ## progressify()
class(progressify) <- c("transpiler", class(progressify))

#' @export
pz <- progressify
