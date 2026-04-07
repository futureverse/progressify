#' @tags pkg-future.apply
if (requireNamespace("future.apply")) {

library(progressify)
library(future.apply)

options(progressify.debug = TRUE)

y <- lapply(X = 1:3, FUN = function(x) {
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

es <- as.environment(xs)


exprs <- list(
  future_lapply = quote(future_lapply(X = xs, FUN = FUN)),
  future_lapply = quote(future.apply::future_lapply(X = xs, FUN = FUN)),
  
  future_sapply = quote(future_sapply(X = xs, FUN = FUN)),
  future_sapply = quote(future.apply::future_sapply(X = xs, FUN = FUN)),
  future_sapply = quote(future.apply::future_sapply(X = xs, FUN = FUN, simplify = FALSE)),
  future_sapply = quote(future.apply::future_sapply(X = xs, FUN = FUN, USE.NAMES = FALSE)),
  
  future_vapply = quote(future.apply::future_vapply(X = xs, FUN.VALUE = NA_real_, FUN = FUN)),
  future_vapply = quote(future.apply::future_vapply(
    X = xs,
    FUN.VALUE = NA_real_,
    FUN = FUN,
    USE.NAMES = FALSE
  )),
  
  future_eapply = quote(future.apply::future_eapply(env = es, FUN = FUN)),
  future_eapply = quote(future.apply::future_eapply(env = es, FUN = FUN, all.names = TRUE)),
  future_eapply = quote(future.apply::future_eapply(env = es, FUN = FUN, USE.NAMES = FALSE)),
  
  future_replicate = quote(future_replicate(10, { 42 })),
  future_replicate = quote(future_replicate(n = 10, { 1 + 2 })),
  future_replicate = quote(future.apply::future_replicate(n = 10, 3 + 4))
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

  #  res <- res[names(truth)]

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

} # if (requireNamespace("future.apply"))
