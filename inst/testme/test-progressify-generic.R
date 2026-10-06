#' @tags pkg-base pkg-stats
library(progressify)

fit <- lm(dist ~ speed, data = cars)

message("*** S3 generic dispatching to a non-supported S3 method")
res <- tryCatch({
  summary(fit) |> progressify()
}, error = identity)
print(res)
stopifnot(
  inherits(res, "error"),
  grepl("dispatches to the S3 method summary.lm()", conditionMessage(res), fixed = TRUE),
  grepl("'lm'|‘lm’", conditionMessage(res))
)


message("*** S3 generic with a dispatch argument that is not a variable")
## The dispatch argument must be evaluated exactly once
counter <- new.env()
counter$n <- 0L
get_fit <- function() {
  counter$n <- counter$n + 1L
  fit
}
res <- tryCatch({
  summary(get_fit()) |> progressify()
}, error = identity)
print(res)
print(counter$n)
stopifnot(
  inherits(res, "error"),
  grepl("dispatches to the S3 method summary.lm()", conditionMessage(res), fixed = TRUE),
  counter$n == 1L
)

## ... which is achieved by deferring it to run time
counter$n <- 0L
expr <- progressify(summary(get_fit()), eval = FALSE)
print(expr)
stopifnot(
  identical(expr[[1]], as.symbol("local")),
  counter$n == 0L
)


message("*** Function that is not part of a package")
my_lapply <- function(X, FUN, ...) lapply(X, FUN, ...)
res <- tryCatch({
  my_lapply(1:3, identity) |> progressify()
}, error = identity)
print(res)
stopifnot(
  inherits(res, "error"),
  grepl("because it is not part of a package", conditionMessage(res), fixed = TRUE)
)


message("*** Errors report the progressify version")
res <- tryCatch({
  progressify({ })
}, error = identity)
print(res)
stopifnot(
  inherits(res, "error"),
  startsWith(conditionMessage(res), "[progressify ")
)
