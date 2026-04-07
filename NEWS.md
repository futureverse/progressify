# Version 0.1.0-9002 (2026-04-07)

## New Features

 * Add support for **crossmap** `future_*()` variants, e.g. `y <-
   crossmap::future_xmap(xs, fcn) |> progressify()`.

 * Add support for **furrr** 0.4.0 `*_vec()` variants:
   `future_map_vec()`, `future_map2_vec()`, `future_pmap_vec()`, and
   `future_imap_vec()`.

 * Add support for `purrr::imap_vec()`.


# Version 0.1.0 (2026-04-01)

This is a retake of the previous, proof-of-concept version. Starting
with this version, we are now borrowing from the **futurize** package,
which implements closely related "parallelization" transpilers.

## New Features

 * Add support for map-reduce CRAN package **future.apply**, e.g. `y
   <- future.apply::future_lapply(xs, fcn) |> progressify()`.

 * Add support for CRAN package **crossmap**, e.g. `y <-
   crossmap::xmap(xs, fcn) |> progressify()`.

 * Add support for **purrr**, e.g. `y <- purrr::map(xs, fcn) |>
   progressify()`.
 
 * Add support for map-reduce CRAN package **furrr**, e.g. `y <-
   furrr::future_map(xs, fcn) |> progressify()`.

 * Add support for map-reduce CRAN package **foreach**, e.g. `y <-
   foreach(x = xs) %do% { fcn(x) } |> progressify()`.

 * Add support for map-reduce CRAN package **doFuture**, e.g. `y <-
   foreach(x = xs) %dofuture% { fcn(x) } |> progressify()`.

 * Add support for **plyr**, e.g. `y <- plyr::llply(xs, fcn) |>
   progressify()`.
 
 * Add support for `replicate()`, e.g. `y <- replicate(n, rnorm(10))
   |> progressify()`.

 * Add support for base-R package **stats**, e.g. `d2 <-
   dendrapply(d, fcn) |> progressify()`.

 * Add support for domain-specific CRAN package **partykit**, e.g. `y
   <- partykit::cforest(formula, data, ntree = 50L) |> progressify()`.

 * Add `progressify_supported_packages()` and
   `progressify_supported_functions()` for programmatically querying
   which packages and functions are supported by `progressify()`.
 

# Version 0.0.1 (2025-05-06)

## New Features

 * The `progressify()` function makes common map-reduce functions
   report on progress. Progress notifications are relayed, among
   other things.
 * Add support for base R, e.g. `y <- lapply(xs, fcn) |> progressify()`.

 * Add support for **purrr**, e.g. `y <- map(xs, fcn) |> progressify()`.
 
 * Add support for **foreach**, e.g. `y <- foreach(x = xs) %do% {
   fcn(x) } |> progressify()`.
 
 * Add support for **plyr**, e.g. `y <- llply(xs, fcn) |>
   progressify()`.

