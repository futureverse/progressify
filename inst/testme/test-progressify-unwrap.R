#' @tags pkg-base
library(progressify)

options(progressify.debug = TRUE)

xs <- list(aa = 1, bb = 1:2, cc = 1:10)

message("*** withCallingHandlers(lapply(...), ...) |> progressify()")
warnings <- list()
y <- withCallingHandlers(
  lapply(xs, FUN = function(x) {
    if (length(x) == 2) warning("boom")
    sum(x)
  }),
  warning = function(w) {
    warnings <<- c(warnings, list(w))
    invokeRestart("muffleWarning")
  }
) |> progressify()
str(y)
str(warnings)
stopifnot(
  identical(y, lapply(xs, FUN = sum)),
  length(warnings) == 1L,
  conditionMessage(warnings[[1]]) == "boom"
)

expr <- quote(withCallingHandlers(lapply(xs, FUN = sum), warning = identity))
expr_t <- progressify(expr, substitute = FALSE, eval = FALSE)
print(expr_t)
stopifnot(identical(expr_t[[1]], as.name("withCallingHandlers")))
