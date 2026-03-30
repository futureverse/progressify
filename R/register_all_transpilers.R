## This function registered functions that adds transpilers for specific
## packages, without loading those packages.
register_all_transpilers <- function() {
  ## Map-reduce packages (base-R)
  append_builtin_transpilers_for_base()
  append_builtin_transpilers_for_BiocParallel()
  append_builtin_transpilers_for_future.apply()
  append_builtin_transpilers_for_purrr()
  append_builtin_transpilers_for_furrr()
  append_builtin_transpilers_for_plyr()
  append_builtin_transpilers_for_stats()
  append_builtin_transpilers_for_foreach()
  append_builtin_transpilers_for_doFuture()
} ## register_all_transpilers()
