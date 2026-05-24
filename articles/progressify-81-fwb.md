# Progress updates for 'fwb' functions

The **progressify** package allows you to easily add progress reporting
to sequential and parallel map-reduce code by piping to the
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function. Easy!

## TL;DR

``` r

library(progressify)
handlers(global = TRUE)
library(fwb)

# Run fractional weighted bootstrap with progress signaling
my_stat <- function(data, w) coef(lm(mpg ~ cyl, data = data, weights = w))
res <- fwb(data = mtcars, statistic = my_stat, R = 1000) |> progressify()
```

## Introduction

This vignette demonstrates how to use this approach to add progress
reporting to the **[fwb](https://cran.r-project.org/package=fwb)**
package’s main function
[`fwb()`](https://ngreifer.github.io/fwb/reference/fwb.html).

The **fwb** package provides functions for generating fractional
weighted bootstrap replicates. For example,
[`fwb()`](https://ngreifer.github.io/fwb/reference/fwb.html) runs a
statistic function `R` times:

``` r

library(fwb)
my_stat <- function(data, w) coef(lm(mpg ~ cyl, data = data, weights = w))
res <- fwb(data = mtcars, statistic = my_stat, R = 1000)
```

By default, [`fwb()`](https://ngreifer.github.io/fwb/reference/fwb.html)
uses `verbose = TRUE`, which provides progress feedback via the
**[pbapply](https://cran.r-project.org/package=pbapply)** package, where
the style can be controlled via
[`pbapply::pboptions()`](https://peter.solymos.org/pbapply/reference/pboptions.html).

As an alternative, we can use the
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function to report on progress via any combination of **progressr**
reporters. To do this, use:

``` r

library(fwb)

library(progressify)
handlers(global = TRUE)

my_stat <- function(data, w) coef(lm(mpg ~ cyl, data = data, weights = w))
res <- fwb(data = mtcars, statistic = my_stat, R = 1000) |> progressify()
```

Comment: This will disable the built-in progress feedback by setting
`verbose = FALSE` in order to avoid dual reporting.

## Supported Functions

The
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function supports the following **fwb** functions:

- [`fwb()`](https://ngreifer.github.io/fwb/reference/fwb.html)
