<!--
%\VignetteIndexEntry{Progress updates for 'future.apply' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{future.apply}
%\VignetteKeyword{vignette}
%\VignetteKeyword{progressify}
%\VignetteEngine{progressify::selfonly}
-->

The **progressify** package allows you to easily add progress
reporting to sequential and parallel map-reduce code by piping to the
`progressify()` function. Easy!


# TL;DR

```r
library(progressify)
handlers(global = TRUE)
library(future.apply)
plan(multisession)

slow_fcn <- function(x) {
  Sys.sleep(0.1)  # emulate work
  x^2
}

xs <- 1:100
ys <- future_lapply(xs, slow_fcn) |> progressify()
```


# Introduction

This vignette demonstrates how to use this approach to add progress
reporting to **[future.apply]** functions such as `future_lapply()`,
`future_tapply()`, `future_apply()`, and `future_replicate()`.

The **future.apply** `future_lapply()` function is commonly used to
apply a function to the elements of a vector or a list in parallel.
For example,

```r
library(future.apply)
plan(multisession)

xs <- 1:100
ys <- future_lapply(xs, slow_fcn)
```

Here `future_lapply()` provides no feedback on how far it has
progressed, but we can easily add progress reporting by using:

```r
library(future.apply)
plan(multisession)

library(progressify)
handlers(global = TRUE)

ys <- future_lapply(xs, slow_fcn) |> progressify()
```

Using the default progress handler, the progress reporting will
appear as:

```plain
  |=====                    |  20%
```


# Supported Functions

The `progressify()` function supports the following **future.apply**
functions:

 * `future_lapply()`, `future_vapply()`, `future_sapply()`, `future_tapply()`
 * `future_mapply()`, `future_.mapply()`, `future_Map()`
 * `future_eapply()`
 * `future_apply()`
 * `future_replicate()`
 * `future_by()`


[future.apply]: https://cran.r-project.org/package=future.apply
