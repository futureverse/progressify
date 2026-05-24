<!--
%\VignetteIndexEntry{Progress updates for 'fwb' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{fwb}
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
library(fwb)

# Run fractional weighted bootstrap with progress signaling
my_stat <- function(data, w) coef(lm(mpg ~ cyl, data = data, weights = w))
res <- fwb(data = mtcars, statistic = my_stat, R = 1000) |> progressify()
```


# Introduction

This vignette demonstrates how to use this approach to add progress
reporting to the **[fwb]** package's main function `fwb()`.

The **fwb** package provides functions for generating fractional weighted bootstrap replicates.
Because these computations are iterative and computationally intensive, they can
benefit significantly from progress reporting.

For example, `fwb()` runs a statistic function `R` times:

```r
library(fwb)
my_stat <- function(data, w) coef(lm(mpg ~ cyl, data = data, weights = w))
res <- fwb(data = mtcars, statistic = my_stat, R = 1000)
```

By default, `fwb()` provides no feedback on how far it has progressed.
However, we can easily add progress reporting using the `progressify()` function:

```r
library(fwb)

library(progressify)
handlers(global = TRUE)

my_stat <- function(data, w) coef(lm(mpg ~ cyl, data = data, weights = w))
res <- fwb(data = mtcars, statistic = my_stat, R = 1000) |> progressify()
```


# Supported Functions

The `progressify()` function supports the following **fwb**
functions:

 * `fwb()`


[fwb]: https://cran.r-project.org/package=fwb
