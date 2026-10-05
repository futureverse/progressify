#' @tags pkg-stats
if (requireNamespace("stats")) {

library(progressify)

options(progressify.debug = TRUE)


## -------------------------------------------------------
## dendrapply
## -------------------------------------------------------
d <- as.dendrogram(hclust(dist(USArrests)))
FUN <- function(node) {
  attr(node, "tested") <- TRUE
  node
}

exprs <- list(
  dendrapply = quote(dendrapply(d, FUN)),
  dendrapply = quote(stats::dendrapply(d, FUN)),
  dendrapply = quote(stats::dendrapply(X = d, FUN = FUN))
)

for (kk in seq_along(exprs)) {
  name <- names(exprs)[kk]
  expr <- exprs[[kk]]
  message()
  message(sprintf("=== %s ==========================", name))
  print(expr)
  message(sprintf("---------------------------------"))
  truth <- eval(expr)

  expr_f <- bquote(.(expr) |> progressify())
  print(expr_f)

  res <- eval(expr_f)

  if (!identical(res, truth)) {
    str(list(truth = truth, res = res))
    stop("Not identical")
  } else {
    str(res)
  }

  out <- utils::capture.output({
    expr_f2 <- bquote(.(expr) |> progressify())
    res2 <- eval(expr_f2)
  })
  print(out)
  stopifnot(identical(out, character(0L)))
  stopifnot(identical(res2, res))

  expr_f3 <- bquote(.(expr) |> progressify())
  res3 <- eval(expr_f3)
  stopifnot(identical(res3, res))
}


## -------------------------------------------------------
## The data argument must be evaluated only once
## -------------------------------------------------------
## Enable progress reporting to force resolve progressor()'s 'steps' and
## 'along' arguments
oopts <- options(progressr.enable = TRUE)

## A function that returns 'value' and counts how many times it is called
n_calls <- 0L
data_of <- function(value) {
  n_calls <<- n_calls + 1L
  value
}

exprs <- list(
  dendrapply = quote(dendrapply(data_of(d), FUN))
)

for (kk in seq_along(exprs)) {
  name <- names(exprs)[kk]
  expr <- exprs[[kk]]
  message(sprintf("=== %s ==========================", name))
  n_calls <- 0L
  truth <- eval(expr)
  stopifnot(n_calls == 1L)

  n_calls <- 0L
  res <- eval(bquote(.(expr) |> progressify()))
  message(sprintf("Number of evaluations: %d", n_calls))
  stopifnot(n_calls == 1L, identical(res, truth))
}

options(oopts)

} # if (requireNamespace("stats"))
