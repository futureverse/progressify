#' @tags pkg-future.apply
if (requireNamespace("future.apply")) {

library(progressify)
library(future.apply)
library(progressr)

options(progressify.debug = TRUE)

## Enable progress reporting so that progressor() actually signals
## 'progression' conditions that we can count below.
options(progressr.enable = TRUE)

## Sequential plan so that progression conditions are signalled in the main
## R session and can be counted with a calling handler (see count_updates()).
plan(sequential)

## A function that both produces output (via message()) and returns a value,
## mimicking a real-world use case, cf. the mapply-bug.R reproducible example.
g <- function(x, b = 2) {
  message("x = ", x)
  sqrt(b * x)
}

xs <- c(1, 2, 3, 4)
bs <- c(4, 3, 2, 1)


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


exprs <- list(
  future_mapply = quote(future_mapply(g, xs, bs)),
  future_mapply = quote(future_mapply(FUN = g, xs, bs)),
  future_mapply = quote(future.apply::future_mapply(g, xs, MoreArgs = list(b = 10))),
  future_mapply = quote(future_mapply(g, xs, bs, SIMPLIFY = FALSE)),
  future_mapply = quote(future_mapply(g, xs, bs, future.seed = TRUE)),

  future_Map = quote(future_Map(g, xs, bs)),
  future_Map = quote(future.apply::future_Map(g, xs, bs)),

  future_.mapply = quote(future_.mapply(g, list(xs, bs), NULL)),
  future_.mapply = quote(future.apply::future_.mapply(g, dots = list(xs, bs), MoreArgs = NULL))
)

for (kk in seq_along(exprs)) {
  name <- names(exprs)[kk]
  expr <- exprs[[kk]]
  message()
  message(sprintf("=== %s ==========================", name))
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

  ## (2) Progress must be reported once per element iterated over
  message(sprintf("Number of progress updates: %d (expected %d)",
                  n_updates, length(xs)))
  stopifnot(identical(n_updates, length(xs)))

  str(res)
}

} # if (requireNamespace("future.apply"))
