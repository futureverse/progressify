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

ints <- 1:6
grp1 <- c("a", "a", "b", "b", "a", "b")   # 2 non-empty groups
grp2 <- c("x", "y", "x", "y", "x", "y")   # grp1 x grp2 -> 4 non-empty combos


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


## tapply() calls FUN once per non-empty group combination of INDEX.
cases <- list(
  list(expr = quote(tapply(ints, grp1, g)),               n = 2L),
  list(expr = quote(tapply(ints, list(grp1, grp2), g)),   n = 4L),
  list(expr = quote(tapply(ints, data.frame(grp1, grp2), g)), n = 4L),
  list(expr = quote(base::tapply(X = ints, INDEX = grp1, FUN = g)), n = 2L),
  ## Unused factor level must not be counted (empty group)
  list(expr = quote(tapply(ints, factor(grp1, levels = c("a", "b", "c")), g)), n = 2L)
)

for (case in cases) {
  expr <- case[["expr"]]
  n_expected <- case[["n"]]
  message()
  message(sprintf("=== tapply ==========================="))
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

  ## (2) Progress must be reported once per non-empty group combination
  message(sprintf("Number of progress updates: %d (expected %d)",
                  n_updates, n_expected))
  stopifnot(identical(n_updates, n_expected))

  str(res)
}


## FUN is optional; without it there is nothing to report and the call is left
## untouched (no progress, no error).
message()
message("=== tapply(FUN = NULL) ===")
res <- tapply(ints, grp1, FUN = NULL) |> progressify()
stopifnot(identical(res, tapply(ints, grp1, FUN = NULL)))
str(res)
