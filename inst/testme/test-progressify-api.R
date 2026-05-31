library(progressify)
options(progressify.debug = TRUE)

# --------------------------------------------------------------------
# progressify()
# --------------------------------------------------------------------
message("progressify(NA):")
res <- progressify(NA)
print(res)
stopifnot(isTRUE(res))

message("progressify(FALSE):")
res <- progressify(FALSE)
print(res)
stopifnot(isTRUE(res))

message("progressify(TRUE):")
res <- progressify(TRUE)
print(res)
stopifnot(isFALSE(res))

if (requireNamespace("progressr", quietly = TRUE)) {
  message("progressify(when = FALSE):")
  y_truth <- lapply(1:3, identity)
  y <- lapply(1:3, identity) |> progressify(when = FALSE)
  stopifnot(identical(y, y_truth))
  y <- lapply(1:3, identity) |> progressify(when = TRUE)
  stopifnot(identical(y, y_truth))
  expr <- lapply(1:3, identity) |> progressify(when = FALSE, eval = FALSE)
  print(expr)
}

## Cannot progressify non-calls
res <- tryCatch(base::pi |> progressify::progressify(), error = identity)
print(res)
stopifnot(inherits(res, "error"))

## Cannot progressify non-calls
res <- tryCatch(quote(1 + 2) |> progressify::progressify(), error = identity)
print(res)
stopifnot(inherits(res, "error"))

## Cannot progressify non-existing functions
res <- tryCatch(progressify:::unknown |> progressify::progressify(), error = identity)
print(res)
stopifnot(inherits(res, "error"))

## Cannot progressify non-existing infix operators
res <- tryCatch(progressify:::`%unknown%` |> progressify::progressify(), error = identity)
print(res)
stopifnot(inherits(res, "error"))

## Cannot progressify non-supported functions
res <- tryCatch(progressify:::progressify_supported_packages() |> progressify::progressify(), error = identity)
print(res)
stopifnot(inherits(res, "error"))

## Cannot progressify private functions
res <- tryCatch(progressify:::import_progressr() |> progressify::progressify(), error = identity)
print(res)
stopifnot(inherits(res, "error"))


# --------------------------------------------------------------------
# progressify_supported_packages() and progressify_supported_functions()
# --------------------------------------------------------------------
pkgs <- progressify_supported_packages()
print(pkgs)

for (pkg in c(pkgs, "progressr", "aNonExistingPackage")) {
  cat(sprintf("Package %s:\n", pkg))
  fcns <- tryCatch({
    progressify::progressify_supported_functions(pkg)
  }, error = identity)
  print(fcns)
}

## Assert that there are not clashes between supported packages
pkgs <- progressify_supported_packages()
for (pkg in rep(pkgs, times = 2L)) {
  cat(sprintf("Package %s:\n", pkg))
  fcns <- tryCatch({
    progressify::progressify_supported_functions(pkg)
  }, error = identity)
  print(fcns)
}
