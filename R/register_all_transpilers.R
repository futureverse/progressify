## This function registered functions that adds transpilers for specific
## packages, without loading those packages.
## # dummy import to please 'R CMD check'
#' @importFrom futurize futurize
register_all_transpilers <- local({
  transpilers_for_package <- import_from("transpilers_for_package", package = "futurize")
  function() {
    debug <- isTRUE(getOption("progressify.debug"))
    if (debug) {
      mdebug_push("progressify:::register_all_transpilers() ...")
      on.exit(mdebug_pop())
    }
    
    ## Built-in
    append_builtin_transpilers_for_base()
  }
}) ## register_all_transpilers()
