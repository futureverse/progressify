#' @tags pkg-base
library(progressify)

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
  lapply = quote(lapply(X = xs, FUN = FUN)),
  lapply = quote(base::lapply(X = xs, FUN = FUN)),
  
  sapply = quote(sapply(X = xs, FUN = FUN)),
  sapply = quote(base::sapply(X = xs, FUN = FUN)),
  sapply = quote(base::sapply(X = xs, FUN = FUN, simplify = FALSE)),
  sapply = quote(base::sapply(X = xs, FUN = FUN, USE.NAMES = FALSE)),
  
  vapply = quote(base::vapply(X = xs, FUN.VALUE = NA_real_, FUN = FUN)),
  vapply = quote(base::vapply(
    X = xs,
    FUN.VALUE = NA_real_,
    FUN = FUN,
    USE.NAMES = FALSE
  )),
  
  eapply = quote(base::eapply(env = es, FUN = FUN)),
  eapply = quote(base::eapply(env = es, FUN = FUN, all.names = TRUE)),
  eapply = quote(base::eapply(env = es, FUN = FUN, USE.NAMES = FALSE)),
  
  replicate = quote(replicate(10, { 42 })),
  replicate = quote(replicate(n = 10, { 1 + 2 })),
  replicate = quote(base::replicate(n = 10, 3 + 4)),

  mapply = quote(mapply(FUN, xs)),
  mapply = quote(mapply(FUN = FUN, xs)),
  mapply = quote(base::mapply(FUN, xs, SIMPLIFY = FALSE)),
  mapply = quote(base::mapply(FUN, xs, USE.NAMES = FALSE)),
  mapply = quote(mapply(FUN, 1:3, MoreArgs = list(na.rm = FALSE))),

  Map = quote(Map(FUN, xs)),
  Map = quote(base::Map(FUN, xs)),

  .mapply = quote(.mapply(FUN, list(xs), NULL)),
  .mapply = quote(base::.mapply(FUN, dots = list(xs), MoreArgs = NULL)),

  apply = quote(apply(m, 1, FUN)),
  apply = quote(apply(m, 2, FUN)),
  apply = quote(apply(X = m, MARGIN = 2, FUN = FUN)),
  apply = quote(base::apply(m, c(1, 2), FUN)),
  apply = quote(apply(m, "cols", FUN)),
  apply = quote(apply(m, 1, FUN, na.rm = FALSE)),
  apply = quote(apply(m, 2, quantile, probs = 0.5)),
  apply = quote(apply(df, 2, FUN)),

  tapply = quote(tapply(ints, grp1, FUN)),
  tapply = quote(tapply(X = ints, INDEX = grp1, FUN = FUN)),
  tapply = quote(base::tapply(ints, list(grp1, grp2), FUN)),
  tapply = quote(tapply(ints, gdf, FUN)),
  tapply = quote(tapply(ints, grp1, FUN, na.rm = FALSE)),
  tapply = quote(tapply(ints, grp1, paste, collapse = "-")),
  tapply = quote(tapply(ints, grp1, sum, default = 0)),
  tapply = quote(tapply(ints, factor(grp1, levels = c("a", "b", "c")), FUN)),
  tapply = quote(tapply(ints, grp1, FUN = NULL))
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

es <- as.environment(xs)

exprs <- list(
  lapply = quote(lapply(data_of(xs), FUN)),
  sapply = quote(sapply(data_of(xs), FUN)),
  vapply = quote(vapply(data_of(xs), FUN, FUN.VALUE = NA_real_)),
  eapply = quote(eapply(data_of(es), FUN)),
  mapply = quote(mapply(FUN, data_of(xs)))
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
