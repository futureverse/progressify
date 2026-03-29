if (requireNamespace("plyr") && requireNamespace("doFuture") && requireNamespace("futurize")) {

library(progressify)
library(futurize)
library(plyr)

options(progressify.debug = TRUE)

xs <- list(aa = 1, bb = 1:2, cc = 1:10, dd = 1:5, .ee = -6:6)
FUN <- function(x, na.rm = TRUE) {
  a <- 1:5
  add <- NULL
  if (length(x) == 2) add <- list(C = 42)
  median(c(a, x), na.rm = na.rm)
}


## -------------------------------------------------------
## l*ply
## -------------------------------------------------------
exprs <- list(
  llply = quote(llply(xs, FUN)),
  llply = quote(plyr::llply(xs, FUN)),
  llply = quote(plyr::llply(.data = xs, .fun = FUN)),

  ldply = quote(plyr::ldply(.data = xs, .fun = function(x) data.frame(med = median(c(1:5, x))))),

  laply = quote(plyr::laply(.data = xs, .fun = function(x) median(c(1:5, x)))),

  l_ply = quote(l_ply(xs, FUN)),
  l_ply = quote(plyr::l_ply(xs, FUN))
)

for (kk in seq_along(exprs)) {
  name <- names(exprs)[kk]
  expr <- exprs[[kk]]
  message()
  message(sprintf("=== %s ==========================", name))
  print(expr)
  message(sprintf("---------------------------------"))
  truth <- eval(expr)

  expr_f <- bquote(.(expr) |> progressify() |> futurize())
  print(expr_f)

  res <- eval(expr_f)

  if (!identical(res, truth)) {
    str(list(truth = truth, res = res))
    stop("Not identical")
  } else {
    str(res)
  }

  out <- utils::capture.output({
    expr_f2 <- bquote(.(expr) |> progressify() |> futurize())
    res2 <- eval(expr_f2)
  })
  print(out)
  stopifnot(identical(out, character(0L)))
  stopifnot(identical(res2, res))

  expr_f3 <- bquote(.(expr) |> progressify() |> futurize())
  res3 <- eval(expr_f3)
  stopifnot(identical(res3, res))
}


## -------------------------------------------------------
## m*ply
## -------------------------------------------------------
args_df <- data.frame(x = 1:5, y = 6:10)
FUN_m <- function(x, y) x + y

exprs <- list(
  mlply = quote(plyr::mlply(.data = args_df, .fun = FUN_m)),

  mdply = quote(plyr::mdply(.data = args_df, .fun = FUN_m)),

  maply = quote(plyr::maply(.data = args_df, .fun = FUN_m)),

  m_ply = quote(plyr::m_ply(.data = args_df, .fun = FUN_m))
)

for (kk in seq_along(exprs)) {
  name <- names(exprs)[kk]
  expr <- exprs[[kk]]
  message()
  message(sprintf("=== %s ==========================", name))
  print(expr)
  message(sprintf("---------------------------------"))
  truth <- eval(expr)

  expr_f <- bquote(.(expr) |> progressify() |> futurize())
  print(expr_f)

  res <- eval(expr_f)

  if (!identical(res, truth)) {
    str(list(truth = truth, res = res))
    stop("Not identical")
  } else {
    str(res)
  }

  out <- utils::capture.output({
    expr_f2 <- bquote(.(expr) |> progressify() |> futurize())
    res2 <- eval(expr_f2)
  })
  print(out)
  stopifnot(identical(out, character(0L)))
  stopifnot(identical(res2, res))

  expr_f3 <- bquote(.(expr) |> progressify() |> futurize())
  res3 <- eval(expr_f3)
  stopifnot(identical(res3, res))
}

} # if (requireNamespace("plyr") && requireNamespace("doFuture") && requireNamespace("futurize"))
