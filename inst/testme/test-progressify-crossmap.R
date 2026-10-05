#' @tags pkg-crossmap
if (requireNamespace("crossmap")) {

library(progressify)
library(crossmap)

options(progressify.debug = TRUE)

## Enable progress reporting to force resolve progressor()'s 'steps' and
## 'along' arguments
options(progressr.enable = TRUE)

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
## xwalk
## -------------------------------------------------------
res_walk <- list()
truth_walk <- list()

expr <- quote(xwalk(xs, function(x, y) { list(x = x, y = y) }))
truth <- eval(expr)
res_walk_truth <- res_walk

res_walk <- list()
expr_f <- bquote(.(expr) |> progressify())
res <- eval(expr_f)
stopifnot(identical(res_walk, res_walk_truth))


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
  pmap_vec_empty = quote(crossmap::pmap_vec(list(), fcn)),
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
## A function that returns 'value' and counts how many times it is called
n_calls <- 0L
data_of <- function(value) {
  n_calls <<- n_calls + 1L
  value
}

exprs <- list(
  xmap = quote(xmap(data_of(xs), fcn)),
  xmap_dbl = quote(xmap_dbl(data_of(xs), ~ .y * .x))
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


## -------------------------------------------------------
## The wrapped .f must not carry a copy of the data
## -------------------------------------------------------
big <- lapply(1:3, function(i) rnorm(30000))  ## ~0.7 MB

## Size of the largest object in the environments of the wrapped .f that
## calls this function, up to the global environment. Those environments
## are exported along with .f to parallel workers.
fun_env_weight <- function(...) {
  env <- parent.env(parent.frame())
  weight <- 0
  while (!identical(env, globalenv()) && !identical(env, emptyenv())) {
    for (name in ls(env, all.names = TRUE)) {
      size <- as.numeric(object.size(get(name, envir = env)))
      weight <- max(weight, size)
    }
    env <- parent.env(env)
  }
  weight
}

exprs <- list(
  xmap = quote(xmap(list(big, 1:2), fun_env_weight))
)

for (kk in seq_along(exprs)) {
  name <- names(exprs)[kk]
  expr <- exprs[[kk]]
  message(sprintf("=== %s ==========================", name))
  res <- eval(bquote(.(expr) |> progressify()))
  weight <- max(unlist(res))
  message(sprintf("Largest object in environment of .f: %.0f bytes", weight))
  stopifnot(weight < as.numeric(object.size(big)) / 2)
}

} # if (requireNamespace("crossmap"))
