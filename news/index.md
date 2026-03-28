# Changelog

## Version (development version)

This is a retake of the previous, proof-of-concept version. Starting
with this version, we are now borrowing from the **futurize** package,
which implements closely related “parallelization” transpilers.

### New Features

- Add support for map-reduce CRAN package **doFuture**,
  e.g. `y <- foreach(x = xs) %dofuture% { fcn(x) } |> progressify()`.

- Add support for map-reduce CRAN package **foreach**,
  e.g. `y <- foreach(x = xs) %do% { fcn(x) } |> progressify()`.

- Add support for map-reduce CRAN package **furrr**,
  e.g. `y <- furrr::future_map(xs, fcn) |> progressify()`.

- Add support for map-reduce CRAN package **future.apply**,
  e.g. `y <- future.apply::future_lapply(xs, fcn) |> progressify()`.

- Add support for **plyr**,
  e.g. `y <- plyr::llply(xs, fcn) |> progressify()`.

- Add support for **purrr**,
  e.g. `y <- purrr::map(xs, fcn) |> progressify()`.

- Add support for [`replicate()`](https://rdrr.io/r/base/lapply.html),
  e.g. `y <- replicate(n, rnorm(10)) |> progressify()`.

## Version 0.0.1

### New Features

- The
  [`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
  function makes common map-reduce functions to report on progress.ons
  are relayed, among other things.

- Add support for base R, e.g. `y <- lapply(xs, fcn) |> progressify()`.

- Add support for **purrr**, e.g. `y <- map(xs, fcn) |> progressify()`.

- Add support for **foreach**,
  e.g. `y <- foreach(x = xs) %do% { fcn(x) } |> progressify()`.

- Add support for **plyr**, e.g. `y <- llply(xs, fcn) |> progressify()`.
