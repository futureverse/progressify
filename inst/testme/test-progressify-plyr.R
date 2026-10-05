#' @tags pkg-plyr
if (requireNamespace("plyr")) {

library(progressify)
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
## r*ply
## -------------------------------------------------------
exprs <- list(
  rlply = quote(plyr::rlply(.n = 5, .expr = { median(1:5) })),

  rdply = quote(plyr::rdply(.n = 5, .expr = data.frame(med = median(1:5)))),

  raply = quote(plyr::raply(.n = 5, .expr = median(1:5))),

  r_ply = quote(plyr::r_ply(.n = 5, .expr = { median(1:5) }))
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
  rlply = quote(plyr::rlply(.n = data_of(3L), .expr = 42)),
  raply = quote(plyr::raply(.n = data_of(3L), .expr = 42))
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

} # if (requireNamespace("plyr"))
