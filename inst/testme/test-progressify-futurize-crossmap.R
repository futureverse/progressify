#' @tags pkg-crossmap
#' @tags pkg-futurize
if (requireNamespace("crossmap") && requireNamespace("futurize")) {

library(progressify)
library(futurize)
library(crossmap)
plan(sequential)

options(progressify.debug = FALSE)

xs <- list(1:5, 1:5)
fcn <- function(x, y) x * y


## -------------------------------------------------------
## xmap family
## -------------------------------------------------------
exprs <- list(
  xmap     = quote(xmap(xs, fcn)),
  xmap     = quote(crossmap::xmap(xs, fcn)),
  xmap     = quote(crossmap::xmap(.l = xs, .f = fcn)),
  xmap_dbl = quote(xmap_dbl(xs, ~ .y * .x)),
  xmap_dbl = quote(crossmap::xmap_dbl(xs, ~ .y * .x)),
  xmap_int = quote(xmap_int(xs, ~ .y * .x)),
  xmap_chr = quote(xmap_chr(xs, ~ paste(.y, "*", .x, "=", .y * .x))),
  xmap_lgl = quote(xmap_lgl(xs, ~ .y > .x)),
  xmap_vec = quote(xmap_vec(xs, fcn))
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


## -------------------------------------------------------
## xwalk
## -------------------------------------------------------
for (pipe in c("progressify_futurize", "futurize_progressify")) {
  res_walk <- list()

  expr <- quote(xwalk(xs, function(x, y) { invisible(list(x = x, y = y)) }))
  truth <- eval(expr)
  res_walk_truth <- res_walk

  res_walk <- list()
  if (pipe == "progressify_futurize") {
    expr_f <- bquote(.(expr) |> progressify() |> futurize())
  } else {
    expr_f <- bquote(.(expr) |> futurize() |> progressify())
  }
  message(sprintf("--- xwalk %s ---", pipe))
  print(expr_f)
  stopifnot(all.equal(res_walk, res_walk_truth))
  stopifnot(identical(res_walk, res_walk_truth))
}


## -------------------------------------------------------
## xmap_mat, xmap_arr
## -------------------------------------------------------
exprs <- list(
  xmap_mat = quote(xmap_mat(xs, fcn)),
  xmap_mat = quote(crossmap::xmap_mat(.l = xs, .f = fcn)),
  xmap_arr = quote(xmap_arr(xs, fcn))
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


## -------------------------------------------------------
## purrr-extension *_vec functions
## -------------------------------------------------------
ys <- 1:5
fcn2 <- function(x) x^2

exprs <- list(
  map_vec  = quote(map_vec(ys, fcn2)),
  map_vec  = quote(crossmap::map_vec(ys, fcn2)),
  map2_vec = quote(map2_vec(ys, ys, fcn)),
  map2_vec = quote(crossmap::map2_vec(ys, ys, fcn)),
  pmap_vec = quote(pmap_vec(list(ys, ys), fcn)),
  pmap_vec = quote(crossmap::pmap_vec(list(ys, ys), fcn)),
  imap_vec = quote(imap_vec(ys, ~ .x + .y)),
  imap_vec = quote(crossmap::imap_vec(ys, ~ .x + .y))
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

} # if (requireNamespace("crossmap") && requireNamespace("futurize"))
