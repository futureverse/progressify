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

} # if (requireNamespace("foreach"))
