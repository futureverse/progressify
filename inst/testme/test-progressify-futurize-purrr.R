if (requireNamespace("purrr") && requireNamespace("furrr") && requireNamespace("futurize")) {

library(progressify)
library(futurize)
library(purrr)

options(progressify.debug = TRUE)

xs <- list(aa = 1, bb = 1:2, cc = 1:10, dd = 1:5, .ee = -6:6)
FUN <- function(x, na.rm = TRUE) {
  a <- 1:5
  add <- NULL
  if (length(x) == 2) {
    add <- list(C = 42)
  }
  median(c(a, x), na.rm = na.rm)
}

ys <- list(aa = 10, bb = 20:21, cc = 30:39, dd = 40:44, .ee = 50:60)
FUN2 <- function(x, y) {
  sum(x) + sum(y)
}


exprs <- list(
  map = quote(map(xs, FUN)),
  map = quote(purrr::map(xs, FUN)),
  map = quote(purrr::map(.x = xs, .f = FUN)),

  map_lgl = quote(purrr::map_lgl(.x = xs, .f = function(x) length(x) > 1)),

  map_int = quote(purrr::map_int(.x = xs, .f = length)),

  map_dbl = quote(purrr::map_dbl(.x = xs, .f = function(x) median(c(1:5, x)))),

  map_chr = quote(purrr::map_chr(.x = xs, .f = function(x) as.character(length(x)))),

  walk = quote(purrr::walk(.x = xs, .f = function(x) invisible(NULL))),

  imap = quote(purrr::imap(xs, function(x, idx) list(idx = idx, len = length(x)))),
  imap_int = quote(purrr::imap_int(xs, function(x, idx) nchar(idx))),

  map2 = quote(purrr::map2(.x = xs, .y = ys, .f = FUN2)),
  map2 = quote(map2(xs, ys, FUN2)),
  map2_dbl = quote(purrr::map2_dbl(.x = xs, .y = ys, .f = FUN2)),

  walk2 = quote(purrr::walk2(.x = xs, .y = ys, .f = function(x, y) invisible(NULL))),

  pmap = quote(purrr::pmap(.l = list(xs, ys), .f = FUN2)),
  pmap = quote(pmap(list(xs, ys), FUN2)),
  pmap_dbl = quote(purrr::pmap_dbl(.l = list(xs, ys), .f = FUN2)),

  pwalk = quote(purrr::pwalk(.l = list(xs, ys), .f = function(x, y) invisible(NULL)))
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

} # if (requireNamespace("purrr") && requireNamespace("furrr") && requireNamespace("futurize"))
