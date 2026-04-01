#' @tags pkg-furrr
if (requireNamespace("furrr")) {

library(progressify)
library(furrr)

options(progressify.debug = TRUE)

y <- future_map(1:3, function(x) {
  print(x)
}) |> progressify()
print(y)


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
  future_map = quote(future_map(xs, FUN)),
  future_map = quote(furrr::future_map(xs, FUN)),
  future_map = quote(furrr::future_map(.x = xs, .f = FUN)),

  future_map_lgl = quote(furrr::future_map_lgl(.x = xs, .f = function(x) length(x) > 1)),

  future_map_int = quote(furrr::future_map_int(.x = xs, .f = length)),

  future_map_dbl = quote(furrr::future_map_dbl(.x = xs, .f = function(x) median(c(1:5, x)))),

  future_map_chr = quote(furrr::future_map_chr(.x = xs, .f = function(x) as.character(length(x)))),

  future_walk = quote(furrr::future_walk(.x = xs, .f = function(x) invisible(NULL))),

  future_imap = quote(furrr::future_imap(xs, function(x, idx) list(idx = idx, len = length(x)))),
  future_imap_int = quote(furrr::future_imap_int(xs, function(x, idx) nchar(idx))),

  future_map2 = quote(furrr::future_map2(.x = xs, .y = ys, .f = FUN2)),
  future_map2 = quote(future_map2(xs, ys, FUN2)),
  future_map2_dbl = quote(furrr::future_map2_dbl(.x = xs, .y = ys, .f = FUN2)),

  future_walk2 = quote(furrr::future_walk2(.x = xs, .y = ys, .f = function(x, y) invisible(NULL))),

  future_pmap = quote(furrr::future_pmap(.l = list(xs, ys), .f = FUN2)),
  future_pmap = quote(future_pmap(list(xs, ys), FUN2)),
  future_pmap_dbl = quote(furrr::future_pmap_dbl(.l = list(xs, ys), .f = FUN2)),

  future_pwalk = quote(furrr::future_pwalk(.l = list(xs, ys), .f = function(x, y) invisible(NULL)))
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

} # if (requireNamespace("furrr"))
