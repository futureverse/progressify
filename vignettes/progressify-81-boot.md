<!--
%\VignetteIndexEntry{Progress updates for 'boot' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{boot}
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
library(boot)

# Run bootstrap with progress signaling
x <- 1:100
my_stat <- function(data, i) mean(data[i])
res <- boot(data = x, statistic = my_stat, R = 1000) |> progressify()
```


# Introduction

This vignette demonstrates how to use this approach to add progress
reporting to **[boot]** functions such as `boot()`, `censboot()`, and `tsboot()`.

The **boot** package provides functions for generating bootstrap replicates.
Because these computations are iterative and computationally intensive, they can
benefit significantly from progress reporting.

For example, `boot()` runs a statistic function `R` times:

```r
library(boot)
x <- 1:100
my_stat <- function(data, i) mean(data[i])
res <- boot(data = x, statistic = my_stat, R = 1000)
```

By default, `boot()` provides no feedback on how far it has progressed.
However, we can easily add progress reporting using the `progressify()` function:

```r
library(boot)

library(progressify)
handlers(global = TRUE)

x <- 1:100
my_stat <- function(data, i) mean(data[i])
res <- boot(data = x, statistic = my_stat, R = 1000) |> progressify()
```


# Supported Functions

The `progressify()` function supports the following **boot**
functions:

 * `boot()`
 * `censboot()`
 * `tsboot()`


[boot]: https://cran.r-project.org/package=boot
