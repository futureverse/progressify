#' @tags pkg-base

library(progressify)
library(progressr)

options(progressify.debug = TRUE)

## Enable progress reporting so that progressor() actually signals
## 'progression' conditions that we can count below.
options(progressr.enable = TRUE)

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
  mapply = quote(mapply(g, xs, bs)),
  mapply = quote(mapply(FUN = g, xs, bs)),
  mapply = quote(base::mapply(g, xs, MoreArgs = list(b = 10))),
  mapply = quote(mapply(g, xs, bs, SIMPLIFY = FALSE)),

  Map = quote(Map(g, xs, bs)),
  Map = quote(base::Map(g, xs, bs)),

  .mapply = quote(.mapply(g, list(xs, bs), NULL)),
  .mapply = quote(base::.mapply(g, dots = list(xs, bs), MoreArgs = NULL))
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
