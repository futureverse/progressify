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
## future_xmap family
## -------------------------------------------------------
exprs <- list(
  future_xmap     = quote(future_xmap(xs, fcn)),
  future_xmap     = quote(crossmap::future_xmap(xs, fcn)),
  future_xmap     = quote(crossmap::future_xmap(.l = xs, .f = fcn)),
  future_xmap_dbl = quote(future_xmap_dbl(xs, ~ .y * .x)),
  future_xmap_dbl = quote(crossmap::future_xmap_dbl(xs, ~ .y * .x)),
  future_xmap_int = quote(future_xmap_int(xs, ~ .y * .x)),
  future_xmap_chr = quote(future_xmap_chr(xs, ~ paste(.y, "*", .x, "=", .y * .x))),
  future_xmap_lgl = quote(future_xmap_lgl(xs, ~ .y > .x)),
  future_xmap_vec = quote(future_xmap_vec(xs, fcn))
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
## future_xwalk
## -------------------------------------------------------
res_walk <- list()
truth_walk <- list()

expr <- quote(future_xwalk(xs, function(x, y) { list(x = x, y = y) }))
truth <- eval(expr)
res_walk_truth <- res_walk

res_walk <- list()
expr_f <- bquote(.(expr) |> progressify())
res <- eval(expr_f)
stopifnot(identical(res_walk, res_walk_truth))


## -------------------------------------------------------
## future_xmap_mat, future_xmap_arr
## -------------------------------------------------------
exprs <- list(
  future_xmap_mat = quote(future_xmap_mat(xs, fcn)),
  future_xmap_mat = quote(crossmap::future_xmap_mat(.l = xs, .f = fcn)),
  future_xmap_arr = quote(future_xmap_arr(xs, fcn))
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
## future purrr-extension *_vec functions
## -------------------------------------------------------
ys <- 1:5
fcn2 <- function(x) x^2

exprs <- list(
  future_map_vec  = quote(future_map_vec(ys, fcn2)),
  future_map_vec  = quote(crossmap::future_map_vec(ys, fcn2)),
  future_map2_vec = quote(future_map2_vec(ys, ys, fcn)),
  future_map2_vec = quote(crossmap::future_map2_vec(ys, ys, fcn)),
  future_pmap_vec = quote(future_pmap_vec(list(ys, ys), fcn)),
  future_pmap_vec = quote(crossmap::future_pmap_vec(list(ys, ys), fcn)),
  future_pmap_vec_empty = quote(crossmap::future_pmap_vec(list(), fcn)),
  future_imap_vec = quote(future_imap_vec(ys, ~ .x + .y)),
  future_imap_vec = quote(crossmap::future_imap_vec(ys, ~ .x + .y))
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
  future_xmap = quote(future_xmap(data_of(xs), fcn)),
  future_xmap_dbl = quote(future_xmap_dbl(data_of(xs), ~ .y * .x))
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
  future_xmap = quote(future_xmap(list(big, 1:2), fun_env_weight))
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
