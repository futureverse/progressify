# Progress updates for 'furrr' functions

The **progressify** package allows you to easily add progress reporting
to sequential and parallel map-reduce code by piping to the
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function. Easy!

## TL;DR

``` r

library(furrr)
plan(multisession)
library(progressify)
library(progressr)
handlers(global = TRUE)

slow_fcn <- function(x) {
  Sys.sleep(0.1)  # emulate work
  x^2
}

xs <- 1:100
ys <- xs |> future_map(slow_fcn) |> progressify()
```

## Introduction

This vignette demonstrates how to use this approach to add progress
reporting to **[furrr](https://cran.r-project.org/package=furrr)**
functions such as
[`future_map()`](https://furrr.futureverse.org/reference/future_map.html),
[`future_map_dbl()`](https://furrr.futureverse.org/reference/future_map.html),
and
[`future_walk()`](https://furrr.futureverse.org/reference/future_map.html).

The **furrr**
[`future_map()`](https://furrr.futureverse.org/reference/future_map.html)
function is commonly used to apply a function to the elements of a
vector or a list in parallel. For example,

``` r

library(furrr)
plan(multisession)

xs <- 1:100
ys <- xs |> future_map(slow_fcn)
```

Here
[`future_map()`](https://furrr.futureverse.org/reference/future_map.html)
provides no feedback on how far it has progressed, but we can easily add
progress reporting, by using:

``` r

library(furrr)
plan(multisession)

library(progressify)
library(progressr)
handlers(global = TRUE)

xs <- 1:100
ys <- xs |> future_map(slow_fcn) |> progressify()
```

Using the default progress handler, the progress reporting will appear
as:

``` plain
  |=====                    |  20%
```

## Supported Functions

The
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function supports the following **furrr** functions:

- [`future_map()`](https://furrr.futureverse.org/reference/future_map.html),
  [`future_map_chr()`](https://furrr.futureverse.org/reference/future_map.html),
  [`future_map_dbl()`](https://furrr.futureverse.org/reference/future_map.html),
  [`future_map_int()`](https://furrr.futureverse.org/reference/future_map.html),
  [`future_map_lgl()`](https://furrr.futureverse.org/reference/future_map.html),
  [`future_map_raw()`](https://furrr.futureverse.org/reference/future_map.html),
  [`future_map_dfr()`](https://furrr.futureverse.org/reference/future_map.html),
  [`future_map_dfc()`](https://furrr.futureverse.org/reference/future_map.html),
  [`future_map_at()`](https://furrr.futureverse.org/reference/future_map_if.html),
  [`future_map_if()`](https://furrr.futureverse.org/reference/future_map_if.html),
  [`future_walk()`](https://furrr.futureverse.org/reference/future_map.html)
- [`future_map2()`](https://furrr.futureverse.org/reference/future_map2.html),
  [`future_map2_chr()`](https://furrr.futureverse.org/reference/future_map2.html),
  [`future_map2_dbl()`](https://furrr.futureverse.org/reference/future_map2.html),
  [`future_map2_int()`](https://furrr.futureverse.org/reference/future_map2.html),
  [`future_map2_lgl()`](https://furrr.futureverse.org/reference/future_map2.html),
  [`future_map2_raw()`](https://furrr.futureverse.org/reference/future_map2.html),
  [`future_map2_dfr()`](https://furrr.futureverse.org/reference/future_map2.html),
  [`future_map2_dfc()`](https://furrr.futureverse.org/reference/future_map2.html),
  [`future_walk2()`](https://furrr.futureverse.org/reference/future_map2.html)
- [`future_pmap()`](https://furrr.futureverse.org/reference/future_map2.html),
  [`future_pmap_chr()`](https://furrr.futureverse.org/reference/future_map2.html),
  [`future_pmap_dbl()`](https://furrr.futureverse.org/reference/future_map2.html),
  [`future_pmap_int()`](https://furrr.futureverse.org/reference/future_map2.html),
  [`future_pmap_lgl()`](https://furrr.futureverse.org/reference/future_map2.html),
  [`future_pmap_raw()`](https://furrr.futureverse.org/reference/future_map2.html),
  [`future_pmap_dfr()`](https://furrr.futureverse.org/reference/future_map2.html),
  [`future_pmap_dfc()`](https://furrr.futureverse.org/reference/future_map2.html),
  [`future_pwalk()`](https://furrr.futureverse.org/reference/future_map2.html)
- [`future_imap()`](https://furrr.futureverse.org/reference/future_imap.html),
  [`future_imap_chr()`](https://furrr.futureverse.org/reference/future_imap.html),
  [`future_imap_dbl()`](https://furrr.futureverse.org/reference/future_imap.html),
  [`future_imap_int()`](https://furrr.futureverse.org/reference/future_imap.html),
  [`future_imap_lgl()`](https://furrr.futureverse.org/reference/future_imap.html),
  [`future_imap_raw()`](https://furrr.futureverse.org/reference/future_imap.html),
  [`future_imap_dfr()`](https://furrr.futureverse.org/reference/future_imap.html),
  [`future_imap_dfc()`](https://furrr.futureverse.org/reference/future_imap.html),
  [`future_iwalk()`](https://furrr.futureverse.org/reference/future_imap.html)
- [`future_modify()`](https://furrr.futureverse.org/reference/future_modify.html),
  [`future_modify_at()`](https://furrr.futureverse.org/reference/future_modify.html),
  [`future_modify_if()`](https://furrr.futureverse.org/reference/future_modify.html)
