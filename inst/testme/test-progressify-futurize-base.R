#' @tags pkg-future.apply
#' @tags pkg-futurize
if (requireNamespace("future.apply") && requireNamespace("futurize")) {

library(progressify)
library(futurize)

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

es <- as.environment(xs)


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
  replicate = quote(base::replicate(n = 10, 3 + 4))
)

for (kk in seq_along(exprs)) {
  name <- names(exprs)[kk]
  expr <- exprs[[kk]]
  message()
  message(sprintf("=== %s ==========================", name))
  print(expr)
  message(sprintf("---------------------------------"))
  truth <- eval(expr)

  for (pipe in c("progressify_futurize", "futurize_progressify")) {
    if (pipe == "progressify_futurize") {
      expr_f <- bquote(.(expr) |> progressify() |> futurize())
    } else {
      expr_f <- bquote(.(expr) |> futurize() |> progressify())
    }
    message(sprintf("--- %s ---", pipe))
    print(expr_f)

    res <- eval(expr_f)

    if (!identical(res, truth)) {
      str(list(truth = truth, res = res))
      stop("Not identical")
    } else {
      str(res)
    }

    out <- utils::capture.output({
      if (pipe == "progressify_futurize") {
        expr_f2 <- bquote(.(expr) |> progressify() |> futurize())
      } else {
        expr_f2 <- bquote(.(expr) |> futurize() |> progressify())
      }
      res2 <- eval(expr_f2)
    })
    print(out)
    stopifnot(identical(out, character(0L)))
    stopifnot(identical(res2, res))

    if (pipe == "progressify_futurize") {
      expr_f3 <- bquote(.(expr) |> progressify() |> futurize())
    } else {
      expr_f3 <- bquote(.(expr) |> futurize() |> progressify())
    }
    res3 <- eval(expr_f3)
    stopifnot(identical(res3, res))
  }
}

} # if (requireNamespace("future.apply") && requireNamespace("futurize"))
