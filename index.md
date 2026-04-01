# progressify: Progress Updates Everywhere ![The 'progressify' hexlogo](reference/figures/progressify-logo.png)

## TL;DR

The **progressify** package makes it extremely simple to report progress
updates for your existing map-reduce calls. All you need to know is that
there is a single function called
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
that will take care of everything, e.g.

``` r

y <- lapply(x, fcn) |> progressify()
y <- map(x, fcn) |> progressify()
y <- foreach(x = xs) %do% { fcn(x) } |> progressify()
```

The
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function signals progress updates via the
**[progressr](https://progressr.futureverse.org)** package, meaning you
can choose among the **[supported progressr
handlers](https://progressr.futureverse.org/articles/progressr-11-handlers.html)**
on how to render progress updates, whether it be via the terminal, a
progress bar, or even a sound. The **progressify** package has only one
hard dependency - the **[progressr](https://progressr.futureverse.org)**
package.

In addition to getting progress updates via **progressr**, by using
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
you also get access to all the benefits that come with **progressr**.
Notably, you have full control over when and how progress is reported,
and it works seamlessly across different environments and frontends.

## Supported map-reduce packages

The **progressify** package supports transpilation of functions from
multiple packages. The table below summarizes the supported map-reduce
functions. To programmatically see which packages are currently
supported, use:

``` r

progressify_supported_packages()
```

To see which functions are supported for a specific package, use:

``` r

progressify_supported_functions("purrr")
```

| Package | Functions |
|----|----|
| **base** | [`apply()`](https://rdrr.io/r/base/apply.html), [`by()`](https://rdrr.io/r/base/by.html), [`eapply()`](https://rdrr.io/r/base/eapply.html), [`lapply()`](https://rdrr.io/r/base/lapply.html), [`.mapply()`](https://rdrr.io/r/base/mapply.html), [`mapply()`](https://rdrr.io/r/base/mapply.html), [`Map()`](https://rdrr.io/r/base/funprog.html), [`replicate()`](https://rdrr.io/r/base/lapply.html), [`sapply()`](https://rdrr.io/r/base/lapply.html), [`tapply()`](https://rdrr.io/r/base/tapply.html), [`vapply()`](https://rdrr.io/r/base/lapply.html) |
| **stats** | [`dendrapply()`](https://rdrr.io/r/stats/dendrapply.html) |
| **[future.apply](https://future.apply.futureverse.org)** | `future_apply()`, `future_by()`, `future_eapply()`, `future_lapply()`, `future_.mapply()`, `future_mapply()`, `future_Map()`, `future_replicate()`, `future_sapply()`, `future_tapply()`, `future_vapply()` |
| **[purrr](https://purrr.futureverse.org)** | `map()` and variants, `walk()` and variants, `map2()` and variants, `walk2()` and variants, `pmap()` and variants, `pwalk()`, `imap()` and variants, `modify()`, `modify2()`, `imodify()` |
| **[crossmap](https://cran.r-project.org/package=crossmap)** | `xmap()` and variants, `xwalk()`, `map_vec()`, `map2_vec()`, `pmap_vec()`, `imap_vec()` |
| **[furrr](https://furrr.futureverse.org)** | `future_map()` and variants, `future_walk()` and variants, `future_map2()` and variants, `future_walk2()` and variants, `future_pmap()` and variants, `future_pwalk()`, `future_imap()` and variants |
| **[foreach](https://foreach.futureverse.org)** | `%do%`, `%dopar%` |
| **[doFuture](https://doFuture.futureverse.org)** | `%dofuture%` |
| **[plyr](https://cran.r-project.org/package=plyr)** | `llply()` and variants, `mlply()` and variants, `rdply()`, `rlply()`, `raply()`, `r_ply()` |
| **[BiocParallel](https://bioconductor.org/packages/BiocParallel)** | `bplapply()`, `bpmapply()` |

*Table 1: Map-reduce functions currently supported by
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
for progress reporting.*

Here are some examples:

``` r

library(progressify)
handlers(globals = TRUE)

xs <- 1:10
ys <- lapply(xs, function(x) { Sys.sleep(0.1); sqrt(x) }) |> progressify()

d <- as.dendrogram(hclust(dist(USArrests)))
d2 <- dendrapply(d, function(n) { Sys.sleep(0.01); n }) |> progressify()

xs <- 1:10
ys <- purrr::map(xs, function(x) { Sys.sleep(0.1); sqrt(x) }) |> progressify()

xs <- list(1:5, 1:5)
ys <- crossmap::xmap(xs, ~ .y * .x) |> progressify()

library(foreach)
xs <- 1:10
ys <- foreach(x = xs) %do% { Sys.sleep(0.1); sqrt(x) } |> progressify()

xs <- 1:10
ys <- plyr::llply(xs, function(x) { Sys.sleep(0.1); sqrt(x) }) |> progressify()

xs <- 1:10
ys <- BiocParallel::bplapply(xs, function(x) { Sys.sleep(0.1); sqrt(x) }) |> progressify()
```

## Supported domain-specific packages

You can also progressify calls from a growing set of domain-specific
CRAN and Bioconductor packages that have optional built-in support for
parallelization.

### CRAN packages with support for progressify

| Package                                                     | Functions   |
|-------------------------------------------------------------|-------------|
| **[partykit](https://cran.r-project.org/package=partykit)** | `cforest()` |

*Table 2: CRAN packages with domain-specific functions currently
supported by
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
for progress reporting.*

Here are some examples:

``` r

forest <- partykit::cforest(Survived ~ ., data = as.data.frame(Titanic), ntree = 50L) |> progressify()
```

## Compatible with futurize

The **progressify** package is compatible with the
**[futurize](https://futurize.futureverse.org)** package, which
parallelizes code via the [futureverse](https://www.futureverse.org).
You can combine the two, in either order, to get both progress reporting
and parallelization:

``` r

library(progressify)
handlers(globals = TRUE)

library(futurize)
plan(multisession)

xs <- 1:100
ys <- lapply(xs, slow_fcn) |> progressify() |> futurize()

ys <- purrr::map(xs, slow_fcn) |> progressify() |> futurize()

library(foreach)
ys <- foreach(x = xs) %do% { slow_fcn(x) } |> progressify() |> futurize()

ys <- plyr::llply(xs, slow_fcn) |> progressify() |> futurize()

ys <- BiocParallel::bplapply(xs, slow_fcn) |> progressify() |> futurize()

forest <- partykit::cforest(dist ~ speed, data = cars, ntree = 50L) |> progressify() |> futurize()
```
