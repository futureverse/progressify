# Changelog

## Version (development version)

- …

## Version 0.2.0

### Significant Changes

- Changed the package license to Apache License (\>= 2).

### New Features

- Add support for domain-specific CRAN package **boot**,
  e.g. `res <- boot::boot(data, statistic, R = 100) |> progressify()`.

- Add support for **crossmap** `future_*()` variants,
  e.g. `y <- crossmap::future_xmap(xs, fcn) |> progressify()`.

- Add support for **furrr** 0.4.0 `*_vec()` variants:
  [`future_map_vec()`](https://pkg.rossellhayes.com/crossmap/reference/future_map_vec.html),
  [`future_map2_vec()`](https://pkg.rossellhayes.com/crossmap/reference/future_map_vec.html),
  [`future_pmap_vec()`](https://pkg.rossellhayes.com/crossmap/reference/future_map_vec.html),
  and
  [`future_imap_vec()`](https://pkg.rossellhayes.com/crossmap/reference/future_map_vec.html).

- Add support for domain-specific CRAN package **fwb**,
  e.g. `res <- fwb::fwb(data, statistic, R = 100) |> progressify()`.

- Add support for domain-specific CRAN package **lme4**,
  e.g. `res <- lme4::bootMer(fit, statistic, nsim = 100) |> progressify()`.

- Add support for
  [`purrr::imap_vec()`](https://purrr.tidyverse.org/reference/imap.html).

- Add support for domain-specific CRAN package **sandwich**,
  e.g. `v <- sandwich::vcovBS(fit) |> progressify()`.

- Add support for domain-specific CRAN package **SimDesign**,
  e.g. `res <- SimDesign::runSimulation(design, replications, generate, analyse, summarise) |> progressify()`.

## Version 0.1.0

CRAN release: 2026-04-07

This is a retake of the previous, proof-of-concept version. Starting
with this version, we are now borrowing from the **futurize** package,
which implements closely related “parallelization” transpilers.

### New Features

- Add support for map-reduce CRAN package **future.apply**,
  e.g. `y <- future.apply::future_lapply(xs, fcn) |> progressify()`.

- Add support for CRAN package **crossmap**,
  e.g. `y <- crossmap::xmap(xs, fcn) |> progressify()`.

- Add support for **purrr**,
  e.g. `y <- purrr::map(xs, fcn) |> progressify()`.

- Add support for map-reduce CRAN package **furrr**,
  e.g. `y <- furrr::future_map(xs, fcn) |> progressify()`.

- Add support for map-reduce CRAN package **foreach**,
  e.g. `y <- foreach(x = xs) %do% { fcn(x) } |> progressify()`.

- Add support for map-reduce CRAN package **doFuture**,
  e.g. `y <- foreach(x = xs) %dofuture% { fcn(x) } |> progressify()`.

- Add support for **plyr**,
  e.g. `y <- plyr::llply(xs, fcn) |> progressify()`.

- Add support for [`replicate()`](https://rdrr.io/r/base/lapply.html),
  e.g. `y <- replicate(n, rnorm(10)) |> progressify()`.

- Add support for base-R package **stats**,
  e.g. `d2 <- dendrapply(d, fcn) |> progressify()`.

- Add support for domain-specific CRAN package **partykit**,
  e.g. `y <- partykit::cforest(formula, data, ntree = 50L) |> progressify()`.

- Add
  [`progressify_supported_packages()`](https://progressify.futureverse.org/reference/progressify_supported_packages.md)
  and
  [`progressify_supported_functions()`](https://progressify.futureverse.org/reference/progressify_supported_packages.md)
  for programmatically querying which packages and functions are
  supported by
  [`progressify()`](https://progressify.futureverse.org/reference/progressify.md).

## Version 0.0.1

### New Features

- The
  [`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
  function makes common map-reduce functions report on progress.
  Progress notifications are relayed, among other things.

- Add support for base R, e.g. `y <- lapply(xs, fcn) |> progressify()`.

- Add support for **purrr**, e.g. `y <- map(xs, fcn) |> progressify()`.

- Add support for **foreach**,
  e.g. `y <- foreach(x = xs) %do% { fcn(x) } |> progressify()`.

- Add support for **plyr**, e.g. `y <- llply(xs, fcn) |> progressify()`.
