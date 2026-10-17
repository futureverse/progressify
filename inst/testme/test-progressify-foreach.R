#' @tags pkg-foreach
if (requireNamespace("foreach")) {

library(progressify)
library(foreach)

options(progressify.debug = TRUE)

xs <- 1:5
FUN <- function(x) {
  a <- 1:5
  median(c(a, x))
}


## -------------------------------------------------------
## %do%
## -------------------------------------------------------
exprs <- list(
  `%do%` = quote(
    foreach(x = xs, .combine = c) %do% { FUN(x) }
  ),

  `%do%` = quote(
    foreach::foreach(x = xs, .combine = c) %do% { FUN(x) }
  ),

  `%do%` = quote(
    foreach(x = xs) %do% { FUN(x) }
  ),

  `%do%` = quote(
    foreach(x = xs, .combine = list) %do% { FUN(x) }
  )
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
## Nested foreach() via %:% is not supported
## -------------------------------------------------------
exprs <- list(
  `%:%` = quote(
    foreach(x = xs) %:% foreach(y = xs) %do% { x * y }
  ),

  `%:% when()` = quote(
    foreach(x = xs) %:% when(x > 2) %do% { FUN(x) }
  )
)

for (kk in seq_along(exprs)) {
  name <- names(exprs)[kk]
  expr <- exprs[[kk]]
  message()
  message(sprintf("=== %s ==========================", name))
  print(expr)
  expr_f <- bquote(.(expr) |> progressify())
  res <- tryCatch(eval(expr_f), error = identity)
  print(res)
  stopifnot(inherits(res, "error"), grepl("%:%", conditionMessage(res), fixed = TRUE))
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
  `%do%` = quote(
    foreach(x = data_of(xs), .combine = c) %do% { FUN(x) }
  ),

  `%do%` = quote(
    foreach(x = data_of(xs), y = xs, .combine = c) %do% { FUN(x + y) }
  )
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

} # if (requireNamespace("foreach"))
