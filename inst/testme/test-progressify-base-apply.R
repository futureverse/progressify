#' @tags pkg-base

library(progressify)
library(progressr)

options(progressify.debug = TRUE)

## Enable progress reporting so that progressor() actually signals
## 'progression' conditions that we can count below.
options(progressr.enable = TRUE)

## A function that both produces output (via message()) and returns a value,
## mimicking a real-world use case, cf. the mapply-bug.R reproducible example.
g <- function(x) {
  message("sum = ", sum(x))
  sum(x)
}

m <- matrix(1:6, nrow = 2, dimnames = list(rows = c("r1", "r2"),
                                           cols = c("c1", "c2", "c3")))


## Count the number of 'update' progressions signalled while evaluating 'expr'
count_updates <- function(expr) {
  n <- 0L
  res <- withCallingHandlers(
    expr,
    progression = function(p) {
      if (identical(p[["type"]], "update")) n <<- n + 1L
      invokeRestart("muffleProgression")
    }
  )
  attr(res, "n_updates") <- n
  res
}


## apply() calls FUN prod(dim(X)[MARGIN]) times, so the number of progress
## updates depends on MARGIN.
cases <- list(
  list(expr = quote(apply(m, 1, g)),              n = 2L),  # nrow
  list(expr = quote(apply(m, 2, g)),              n = 3L),  # ncol
  list(expr = quote(apply(m, c(1, 2), g)),        n = 6L),  # per cell
  list(expr = quote(apply(m, "cols", g)),         n = 3L),  # dimname MARGIN
  list(expr = quote(base::apply(X = m, MARGIN = 1, FUN = g)), n = 2L)
)

for (case in cases) {
  expr <- case[["expr"]]
  n_expected <- case[["n"]]
  message()
  message(sprintf("=== apply ==========================="))
  print(expr)
  message(sprintf("---------------------------------"))

  ## Truth, i.e. the non-progressified result
  truth <- suppressMessages(eval(expr))

  expr_f <- bquote(.(expr) |> progressify())
  print(expr_f)

  res <- count_updates(suppressMessages(eval(expr_f)))
  n_updates <- attr(res, "n_updates")
  attr(res, "n_updates") <- NULL

  ## (1) The progressified result must equal the non-progressified one
  if (!identical(res, truth)) {
    str(list(truth = truth, res = res))
    stop("Not identical")
  }

  ## (2) Progress must be reported once per margin element iterated over
  message(sprintf("Number of progress updates: %d (expected %d)",
                  n_updates, n_expected))
  stopifnot(identical(n_updates, n_expected))

  str(res)
}
