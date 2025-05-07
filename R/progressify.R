#' Evaluate a regular map-reduce call in parallel
#'
#' @param expr An R expression.
#'
#' @param substitute If TRUE, `expr` is quoted.
#'
#' @param \ldots Not used.
#' 
#' @param envir The environment in which `expr` is evaluated.
#' 
#' @returns
#' Returns the value of the evaluated expression `expr`.
#'
#' @example incl/progressify-base.R
#'
#' @importFrom progressr progressor
#' @export
progressify <- function(expr, substitute = TRUE, ..., envir = parent.frame()) {
  if (substitute) expr <- substitute(expr)
  debug <- isTRUE(getOption("progressify.debug"))
  if (debug) {
    mdebug_push("progressify() ...")
    on.exit(mdebug_pop())
  }
  
  stopifnot(
    is.language(expr),
    is.call(expr)
  )

  ## Identify (namespace, function)
  call <- expr[[1]]
  if (is.symbol(call)) {
    ## Examples: lapply(...), map(...)
    namespace <- NULL
    fcn <- call
  } else if (is.call(call)) {
    stopifnot(length(call) == 3L)
    ## Examples: base::lapply(...), purrr::map(...)
    ## Not supported: base:::lapply(), baseenv()$lapply(...), ...
    op <- call[[1]]
    if (is.symbol(op)) {
      op_name <- as.character(op)
      if (op_name == "::") {
      } else if (op_name == ":::") {
        stop(sprintf("Do not know how to progressify a private function: %s()", deparse(call)))
      } else {
        stop(sprintf("Do not know how to progressify function: %s()", deparse(call)))
      }
      namespace <- call[[2]]
      fcn <- call[[3]]
    } else {
      stop(sprintf("Do not know how to progressify object of type %s: %s()", sQuote(typeof(op)), deparse(call)))
    }
  } else {
    stop(sprintf("Do not know how to progressify function: %s()", as.character(call)))
  }

  ns_name <- as.character(namespace)
  fcn_name <- as.character(fcn)
  if (debug) {
    if (length(ns_name) == 1L) {
      msg <- sprintf("Function: %s::%s(...)", ns_name, fcn_name)
    } else {
      msg <- sprintf("Function: %s(...)", fcn_name)
    }
    mdebug(msg)
  }

  ## Does the function exist?
  if (is.null(namespace)) {
    if (debug) mdebug_push("Locate function ...")
    if (!exists(fcn_name, mode = "function", envir = envir, inherits = TRUE)) {
      stop(sprintf("No such function: %s()", deparse(call)))
    }
    fcn <- get(fcn_name, mode = "function", envir = envir, inherits = TRUE)
    ns_name <- environmentName(environment(fcn))
    if (debug) {
      mdebugf("Function located in: %s", sQuote(ns_name))
      mdebug_pop()
    }
  } else {
    ns <- getNamespace(ns_name)
    if (!exists(fcn_name, mode = "function", envir = ns, inherits = TRUE)) {
      stop(sprintf("No such function in %s: %s()", sQuote(ns_name), deparse(call)))
    }
  }

  if (debug) {
    mdebugf_push("Locating transpiler for %s::%s() ...", ns_name, fcn_name)
  }

  transpiler_sets <- known_fcns
  transpilers <- transpiler_sets[[ns_name]]
  if (debug) {
    mdebugf("Namespaces registered with progressify(): %s", commaq(names(transpiler_sets)))
  }
  
  ## Is there a registered transpiler for the function?
  if (is.null(transpilers)) {
    stop(sprintf("Function %s::%s() is not in one of the registered progressify namespaces: %s", ns_name, fcn_name, commaq(names(transpiler_sets))))
  }

  if (! fcn_name %in% names(transpilers)) {
    stop(sprintf("Do not know how to progressify function: %s()", deparse(call)))
  }
  transpiler <- transpilers[[fcn_name]]
  if (debug) {
#    mdebugf("Transpiler: %s", transpiler[["label"]])
  }
  if (debug) mdebugf_pop()

  if (debug) mdebug("Transpile call expression")
  if (debug) mprint(expr)
  res <- progressify_base(expr, fcn_name = fcn_name, envir = envir)
  if (debug) mprint(res[["t_expr"]])

  if (debug) mdebug("Evaluate transpiled call expression")
  eval(res[["t_expr"]], envir = envir)
} ## progressify()
