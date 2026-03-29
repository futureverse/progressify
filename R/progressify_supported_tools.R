#' List packages and functions supporting progressification
#'
#' @param package A package name.
#'
#' @return
#' A character vector of package or function names.
#'
#' @examples
#' pkgs <- progressify_supported_packages()
#' pkgs
#'
#' fcns <- progressify_supported_functions("base")
#' print(fcns)
#'
#' if (requireNamespace("purrr")) {
#'   fcns <- progressify_supported_functions("purrr")
#'   print(fcns)
#' }
#'
#' @export
progressify_supported_packages <- function() {
  transpilers <- get_transpilers("progressify::built-in")
  sort(names(transpilers))
}


#' @rdname progressify_supported_packages
#' @export
progressify_supported_functions <- function(package) {
  stopifnot(is.character(package), length(package) == 1L, !is.na(package), nzchar(package))

  transpilers <- get_transpilers("progressify::built-in")
  pkg_transpilers <- transpilers[[package]]

  if (is.null(pkg_transpilers) || length(pkg_transpilers) == 0L) {
    stop(sprintf("Package %s does not support progressification", sQuote(package)))
  }

  sort(unique(names(pkg_transpilers)))
}
