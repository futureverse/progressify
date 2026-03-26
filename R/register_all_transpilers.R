## This function registered functions that adds transpilers for specific
## packages, without loading those packages.
register_all_transpilers <- function() {
  ## Map-reduce packages (base-R)
  append_builtin_transpilers_for_base()
} ## register_all_transpilers()
