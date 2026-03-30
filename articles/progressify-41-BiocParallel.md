# Progress updates for 'BiocParallel' functions

The **progressify** package allows you to easily add progress reporting
to sequential and parallel map-reduce code by piping to the
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function. Easy!

## TL;DR

``` r

library(BiocParallel)
library(progressify)
handlers(global = TRUE)

slow_fcn <- function(x) {
  Sys.sleep(0.1)  # emulate work
  x^2
}

xs <- 1:100
ys <- bplapply(xs, slow_fcn) |> progressify()
```

## Introduction

This vignette demonstrates how to use this approach to add progress
reporting to
**[BiocParallel](https://bioconductor.org/packages/BiocParallel)**
functions such as
[`bplapply()`](https://rdrr.io/pkg/BiocParallel/man/bplapply.html) and
[`bpmapply()`](https://rdrr.io/pkg/BiocParallel/man/bpmapply.html).

The **BiocParallel**
[`bplapply()`](https://rdrr.io/pkg/BiocParallel/man/bplapply.html)
function is commonly used to apply a function to the elements of a list
and return a list. For example,

``` r

library(BiocParallel)
xs <- 1:100
ys <- bplapply(xs, slow_fcn)
```

Here [`bplapply()`](https://rdrr.io/pkg/BiocParallel/man/bplapply.html)
provides no feedback on how far it has progressed, but we can easily add
progress reporting, by using:

``` r

library(BiocParallel)

library(progressify)
handlers(global = TRUE)

xs <- 1:100
ys <- bplapply(xs, slow_fcn) |> progressify()
```

Using the default progress handler, the progress reporting will appear
as:

``` plain
  |=====                    |  20%
```

## Supported Functions

The
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function supports the following **BiocParallel** functions:

- [`bplapply()`](https://rdrr.io/pkg/BiocParallel/man/bplapply.html)
- [`bpmapply()`](https://rdrr.io/pkg/BiocParallel/man/bpmapply.html)
