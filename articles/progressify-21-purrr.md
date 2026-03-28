# Progress updates for 'purrr' functions

The **progressify** package allows you to easily add progress reporting
to sequential and parallel map-reduce code by piping to the
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function. Easy!

## TL;DR

``` r

library(progressify)
library(progressr)
handlers(global = TRUE)
library(purrr)

slow_fcn <- function(x) {
  Sys.sleep(0.1)  # emulate work
  x^2
}

xs <- 1:100
ys <- xs |> map(slow_fcn) |> progressify()
```

## Introduction

This vignette demonstrates how to use this approach to add progress
reporting to **[purrr](https://cran.r-project.org/package=purrr)**
functions such as
[`map()`](https://purrr.tidyverse.org/reference/map.html),
[`map_dbl()`](https://purrr.tidyverse.org/reference/map.html), and
[`walk()`](https://purrr.tidyverse.org/reference/map.html).

The **purrr** [`map()`](https://purrr.tidyverse.org/reference/map.html)
function is commonly used to apply a function to the elements of a
vector or a list. For example,

``` r

library(purrr)
xs <- 1:100
ys <- map(xs, slow_fcn)
```

or equivalently using pipe syntax

``` r

xs <- 1:100
ys <- xs |> map(slow_fcn)
```

Here [`map()`](https://purrr.tidyverse.org/reference/map.html) provides
no feedback on how far it has progressed, but we can easily add progress
reporting, by using:

``` r

library(purrr)

library(progressify)
library(progressr)
handlers(global = TRUE)

xs <- 1:100
ys <- xs |> map(slow_fcn) |> progressify()
```

Using the default progress handler, the progress reporting will appear
as:

``` plain
  |=====                    |  20%
```

## Supported Functions

The
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function supports the following **purrr** functions:

- [`map()`](https://purrr.tidyverse.org/reference/map.html),
  [`map_chr()`](https://purrr.tidyverse.org/reference/map.html),
  [`map_dbl()`](https://purrr.tidyverse.org/reference/map.html),
  [`map_int()`](https://purrr.tidyverse.org/reference/map.html),
  [`map_lgl()`](https://purrr.tidyverse.org/reference/map.html),
  [`map_vec()`](https://purrr.tidyverse.org/reference/map.html),
  [`walk()`](https://purrr.tidyverse.org/reference/map.html)
- [`map2()`](https://purrr.tidyverse.org/reference/map2.html),
  [`map2_chr()`](https://purrr.tidyverse.org/reference/map2.html),
  [`map2_dbl()`](https://purrr.tidyverse.org/reference/map2.html),
  [`map2_int()`](https://purrr.tidyverse.org/reference/map2.html),
  [`map2_lgl()`](https://purrr.tidyverse.org/reference/map2.html),
  [`map2_vec()`](https://purrr.tidyverse.org/reference/map2.html),
  [`walk2()`](https://purrr.tidyverse.org/reference/map2.html)
- [`pmap()`](https://purrr.tidyverse.org/reference/pmap.html),
  [`pmap_chr()`](https://purrr.tidyverse.org/reference/pmap.html),
  [`pmap_dbl()`](https://purrr.tidyverse.org/reference/pmap.html),
  [`pmap_int()`](https://purrr.tidyverse.org/reference/pmap.html),
  [`pmap_lgl()`](https://purrr.tidyverse.org/reference/pmap.html),
  [`pmap_vec()`](https://purrr.tidyverse.org/reference/pmap.html),
  [`pwalk()`](https://purrr.tidyverse.org/reference/pmap.html)
- [`imap()`](https://purrr.tidyverse.org/reference/imap.html),
  [`imap_chr()`](https://purrr.tidyverse.org/reference/imap.html),
  [`imap_dbl()`](https://purrr.tidyverse.org/reference/imap.html),
  [`imap_int()`](https://purrr.tidyverse.org/reference/imap.html),
  [`imap_lgl()`](https://purrr.tidyverse.org/reference/imap.html)
- [`modify()`](https://purrr.tidyverse.org/reference/modify.html),
  [`modify2()`](https://purrr.tidyverse.org/reference/modify.html),
  [`imodify()`](https://purrr.tidyverse.org/reference/modify.html)
