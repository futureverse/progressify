<!--
%\VignetteIndexEntry{Progress updates for 'furrr' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{furrr}
%\VignetteKeyword{vignette}
%\VignetteKeyword{progressify}
%\VignetteEngine{progressify::selfonly}
-->

The **progressify** package allows you to easily add progress
reporting to sequential and parallel map-reduce code by piping to the
`progressify()` function. Easy!


# TL;DR

```r
library(furrr)
plan(multisession)
library(progressify)
handlers(global = TRUE)

slow_fcn <- function(x) {
  Sys.sleep(0.1)  # emulate work
  x^2
}

xs <- 1:100
ys <- xs |> future_map(slow_fcn) |> progressify()
```


# Introduction

This vignette demonstrates how to use this approach to add progress
reporting to **[furrr]** functions such as `future_map()`,
`future_map_dbl()`, and `future_walk()`.

The **furrr** `future_map()` function is commonly used to apply a
function to the elements of a vector or a list in parallel. For
example,

```r
library(furrr)
plan(multisession)

xs <- 1:100
ys <- xs |> future_map(slow_fcn)
```

Here `future_map()` provides no feedback on how far it has progressed,
but we can easily add progress reporting by using:

```r
library(furrr)
plan(multisession)

library(progressify)
handlers(global = TRUE)

xs <- 1:100
ys <- xs |> future_map(slow_fcn) |> progressify()
```

Using the default progress handler, the progress reporting will
appear as:

```plain
  |=====                    |  20%
```


# Supported Functions

The `progressify()` function supports the following **furrr** functions:

 * `future_map()`, `future_map_chr()`, `future_map_dbl()`, `future_map_int()`, `future_map_lgl()`, `future_map_raw()`, `future_map_dfr()`, `future_map_dfc()`, `future_map_at()`, `future_map_if()`, `future_walk()`
 * `future_map2()`, `future_map2_chr()`, `future_map2_dbl()`, `future_map2_int()`, `future_map2_lgl()`, `future_map2_raw()`, `future_map2_dfr()`, `future_map2_dfc()`, `future_walk2()`
 * `future_pmap()`, `future_pmap_chr()`, `future_pmap_dbl()`, `future_pmap_int()`, `future_pmap_lgl()`, `future_pmap_raw()`, `future_pmap_dfr()`, `future_pmap_dfc()`, `future_pwalk()`
 * `future_imap()`, `future_imap_chr()`, `future_imap_dbl()`, `future_imap_int()`, `future_imap_lgl()`, `future_imap_raw()`, `future_imap_dfr()`, `future_imap_dfc()`, `future_iwalk()`
 * `future_modify()`, `future_modify_at()`, `future_modify_if()`


[furrr]: https://cran.r-project.org/package=furrr
