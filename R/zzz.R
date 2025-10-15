.package <- new.env(parent = emptyenv())

## covr: skip=all
#' @importFrom utils packageVersion
.onLoad <- function(libname, pkgname) {
  .package[["version"]] <- packageVersion(pkgname)

  update_package_option <- import_from("update_package_option", package = "future")
  update_package_option("progressify.debug", mode = "logical")
  debug <- isTRUE(getOption("progressify.debug"))

  if (debug) {
    envs <- Sys.getenv()
    envs <- envs[grep("R_PROGRESSIFY_", names(envs), fixed = TRUE)]
    envs <- sprintf("- %s=%s", names(envs), sQuote(envs))
    mdebug(paste(c("Progressify-specific environment variables:", envs), collapse = "\n"))
  }

  register_all_transpilers()
} ## .onLoad()
