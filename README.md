<div id="badges"><!-- pkgdown markup -->
<a href="https://github.com/HenrikBengtsson/progressify/actions?query=workflow%3AR-CMD-check"><img border="0" src="https://github.com/HenrikBengtsson/progressify/actions/workflows/R-CMD-check.yaml/badge.svg?branch=main" alt="R CMD check status"/></a>
<!--
<a href="https://app.codecov.io/gh/HenrikBengtsson/progressify"><img border="0" src="https://codecov.io/gh/HenrikBengtsson/progressify/branch/main/graph/badge.svg" alt="Coverage Status"/></a> 
-->
</div>

# progressify: Progress Updates Everywhere

## TL;DR 

The **progressify** package makes it extremely simple to report
progress updates for your existing map-reduce calls. All you need to
know is that there is a single function called `progressify()` that
will take care of everything, e.g.

```r
y <- lapply(x, fcn) |> progressify()
y <- map(x, fcn) |> progressify()
y <- foreach(x = xs) %do% { fcn(x) } |> progressify()
```

The `progressify()` function signals progress updates via the
**[progressr]** package, meaning you can choose among the **[supported
progressr handlers]** on how to render progress updates, whether it be
via the terminal, a progress bar, or even a sound. The **progressify**
package has only one hard dependency - the **[progressr]** package.

In addition to getting progress updates via **progressr**,
by using `progressify()` you also get access to all the benefits that
comes with **progressr**. Notably, you have full control over when
and how progress is reported, and it works seamlessly across
different environments and frontends.


## Supported map-reduce packages

The **progressify** package supports transpilation of functions from
multiple packages. The table below summarizes the supported map-reduce
functions.

| Package            | Functions                                                                                                          |
|--------------------|--------------------------------------------------------------------------------------------------------------------|
| **base**           | `apply()`, `by()`, `eapply()`, `lapply()`, `.mapply()`, `mapply()`, `Map()`, `replicate()`, `sapply()`, `tapply()`, `vapply()` |
| **[future.apply]** | `future_apply()`, `future_by()`, `future_eapply()`, `future_lapply()`, `future_.mapply()`, `future_mapply()`, `future_Map()`, `future_replicate()`, `future_sapply()`, `future_tapply()`, `future_vapply()` |
| **[purrr]**        | `map()` and variants, `walk()` and variants, `map2()` and variants, `walk2()` and variants, `pmap()` and variants, `pwalk()`, `imap()` and variants, `modify()`, `modify2()`, `imodify()` |
| **[furrr]**        | `future_map()` and variants, `future_walk()` and variants, `future_map2()` and variants, `future_walk2()` and variants, `future_pmap()` and variants, `future_pwalk()`, `future_imap()` and variants |
| **[foreach]**      | `%do%`, `%dopar%`                                                                                                  |
| **[doFuture]**     | `%dofuture%`                                                                                                       |
| **[plyr]**         | `llply()` and variants, `mlply()` and variants, `rdply()`, `rlply()`, `raply()`, `r_ply()` |

_Table 1: Map-reduce functions currently supported by `progressify()` for progress reporting._

Here are some examples:

```r
library(progressify)
handlers("txtprogressbar")

xs <- 1:10
ys <- lapply(xs, function(x) { Sys.sleep(0.1); sqrt(x) }) |> progressify()

xs <- 1:10
ys <- purrr::map(xs, function(x) { Sys.sleep(0.1); sqrt(x) }) |> progressify()

library(foreach)
xs <- 1:10
ys <- foreach(x = xs) %do% { Sys.sleep(0.1); sqrt(x) } |> progressify()

xs <- 1:10
ys <- plyr::llply(xs, function(x) { Sys.sleep(0.1); sqrt(x) }) |> progressify()
```


## Compatible with futurize

The **progressify** package is compatible with the **[futurize]**
package, which parallelizes code via the [futureverse]. You can
combine the two, in either order, to get both progress reporting and
parallelization:

```r
library(progressify)
library(futurize)
plan(multisession)

xs <- 1:100
ys <- lapply(xs, slow_fcn) |> progressify() |> futurize()

ys <- purrr::map(xs, slow_fcn) |> progressify() |> futurize()

library(foreach)
ys <- foreach(x = xs) %do% { slow_fcn(x) } |> progressify() |> futurize()

ys <- plyr::llply(xs, slow_fcn) |> progressify() |> futurize()
```


[futurize]: https://futurize.futureverse.org
[futureverse]: https://www.futureverse.org
[progressr]: https://progressr.futureverse.org
[future.apply]: https://future.apply.futureverse.org
[purrr]: https://purrr.futureverse.org
[furrr]: https://furrr.futureverse.org
[doFuture]: https://doFuture.futureverse.org
[foreach]: https://foreach.futureverse.org
[plyr]: https://cran.r-project.org/package=plyr
[supported progressr handlers]: https://progressr.futureverse.org/articles/progressr-11-handlers.html
