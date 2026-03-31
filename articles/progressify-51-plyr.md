# Progress updates for 'plyr' functions

The **progressify** package allows you to easily add progress reporting
to sequential and parallel map-reduce code by piping to the
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function. Easy!

## TL;DR

``` r

library(plyr)
library(progressify)
handlers(global = TRUE)

slow_fcn <- function(x) {
  Sys.sleep(0.1)  # emulate work
  x^2
}

xs <- 1:100
ys <- llply(xs, slow_fcn) |> progressify()
```

## Introduction

This vignette demonstrates how to use this approach to add progress
reporting to **[plyr](https://cran.r-project.org/package=plyr)**
functions such as [`llply()`](https://rdrr.io/pkg/plyr/man/llply.html),
[`maply()`](https://rdrr.io/pkg/plyr/man/maply.html), and
[`ddply()`](https://rdrr.io/pkg/plyr/man/ddply.html).

The **plyr** [`llply()`](https://rdrr.io/pkg/plyr/man/llply.html)
function is commonly used to apply a function to the elements of a list
and return a list. For example,

``` r

library(plyr)
xs <- 1:100
ys <- llply(xs, slow_fcn)
```

Here [`llply()`](https://rdrr.io/pkg/plyr/man/llply.html) provides no
feedback on how far it has progressed, but we can easily add progress
reporting by using:

``` r

library(plyr)

library(progressify)
handlers(global = TRUE)

xs <- 1:100
ys <- llply(xs, slow_fcn) |> progressify()
```

Using the default progress handler, the progress reporting will appear
as:

``` plain
  |=====                    |  20%
```

## Supported Functions

The
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function supports the following **plyr** functions:

- [`l_ply()`](https://rdrr.io/pkg/plyr/man/l_ply.html),
  [`laply()`](https://rdrr.io/pkg/plyr/man/laply.html),
  [`ldply()`](https://rdrr.io/pkg/plyr/man/ldply.html),
  [`llply()`](https://rdrr.io/pkg/plyr/man/llply.html)
- [`m_ply()`](https://rdrr.io/pkg/plyr/man/m_ply.html),
  [`maply()`](https://rdrr.io/pkg/plyr/man/maply.html),
  [`mdply()`](https://rdrr.io/pkg/plyr/man/mdply.html),
  [`mlply()`](https://rdrr.io/pkg/plyr/man/mlply.html)
- [`r_ply()`](https://rdrr.io/pkg/plyr/man/r_ply.html),
  [`raply()`](https://rdrr.io/pkg/plyr/man/raply.html),
  [`rdply()`](https://rdrr.io/pkg/plyr/man/rdply.html),
  [`rlply()`](https://rdrr.io/pkg/plyr/man/rlply.html)
