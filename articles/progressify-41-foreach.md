# Progress updates for 'foreach' functions

The **progressify** package allows you to easily add progress reporting
to sequential and parallel map-reduce code by piping to the
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function. Easy!

## TL;DR

``` r

library(progressify)
handlers(global = TRUE)
library(foreach)

slow_fcn <- function(x) {
  Sys.sleep(0.1)  # emulate work
  x^2
}

xs <- 1:100
ys <- foreach(x = xs) %do% slow_fcn(x) |> progressify()
```

## Introduction

This vignette demonstrates how to use this approach to add progress
reporting to the
**[foreach](https://cran.r-project.org/package=foreach)**
[`foreach()`](https://rdrr.io/pkg/foreach/man/foreach.html) construct
and the **[doFuture](https://cran.r-project.org/package=doFuture)**
`%dofuture%` operator.

For example, consider:

``` r

library(foreach)
xs <- 1:100
ys <- foreach(x = xs) %do% slow_fcn(x)
```

This [`foreach()`](https://rdrr.io/pkg/foreach/man/foreach.html)
construct provides no feedback on how far it has progressed. We can
easily add progress reporting by piping to
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md):

``` r

library(foreach)

library(progressify)
handlers(global = TRUE)

xs <- 1:100
ys <- foreach(x = xs) %do% slow_fcn(x) |> progressify()
```

Using the default progress handler, the progress reporting will appear
as:

``` plain
  |=====                    |  20%
```

### With doFuture

The same approach works with the
**[doFuture](https://cran.r-project.org/package=doFuture)** package for
parallel foreach evaluation:

``` r

library(doFuture)
plan(multisession)

library(progressify)
handlers(global = TRUE)

xs <- 1:100
ys <- foreach(x = xs) %dofuture% slow_fcn(x) |> progressify()
```

## Supported Functions

The
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function supports the following **foreach** operators:

- `foreach(...) %do% { ... }`
- `foreach(...) %dopar% { ... }`

and the following **doFuture** operator:

- `foreach(...) %dofuture% { ... }`
