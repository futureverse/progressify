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

m <- matrix(1:6, nrow = 2, dimnames = list(rows = c("r1", "r2"),
                                           cols = c("c1", "c2", "c3")))
df <- data.frame(a = 1:3, b = 4:6)

ints <- 1:6
grp1 <- c("a", "a", "b", "b", "a", "b")
grp2 <- c("x", "y", "x", "y", "x", "y")
gdf <- data.frame(grp1 = grp1, grp2 = grp2)


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
  future_replicate = quote(future.apply::future_replicate(n = 10, 3 + 4)),

  future_mapply = quote(future_mapply(FUN, xs)),
  future_mapply = quote(future_mapply(FUN = FUN, xs)),
  future_mapply = quote(future.apply::future_mapply(FUN, xs, SIMPLIFY = FALSE)),
  future_mapply = quote(future.apply::future_mapply(FUN, xs, USE.NAMES = FALSE)),
  future_mapply = quote(future_mapply(FUN, 1:3, MoreArgs = list(na.rm = FALSE))),

  future_Map = quote(future_Map(FUN, xs)),
  future_Map = quote(future.apply::future_Map(FUN, xs)),

  future_.mapply = quote(future_.mapply(FUN, list(xs), NULL)),
  future_.mapply = quote(future.apply::future_.mapply(FUN, dots = list(xs), MoreArgs = NULL)),

  future_apply = quote(future_apply(m, 1, FUN)),
  future_apply = quote(future_apply(m, 2, FUN)),
  future_apply = quote(future_apply(X = m, MARGIN = 2, FUN = FUN)),
  future_apply = quote(future.apply::future_apply(m, c(1, 2), FUN)),
  future_apply = quote(future_apply(m, "cols", FUN)),
  future_apply = quote(future_apply(m, 1, FUN, na.rm = FALSE)),
  future_apply = quote(future_apply(m, 2, quantile, probs = 0.5)),
  future_apply = quote(future_apply(df, 2, FUN)),

  future_tapply = quote(future_tapply(ints, grp1, FUN)),
  future_tapply = quote(future_tapply(X = ints, INDEX = grp1, FUN = FUN)),
  future_tapply = quote(future.apply::future_tapply(ints, list(grp1, grp2), FUN)),
  future_tapply = quote(future_tapply(ints, gdf, FUN)),
  future_tapply = quote(future_tapply(ints, grp1, FUN, na.rm = FALSE)),
  future_tapply = quote(future_tapply(ints, grp1, paste, collapse = "-"))
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
