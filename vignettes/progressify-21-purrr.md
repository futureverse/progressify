<!--
%\VignetteIndexEntry{Progress updates for 'purrr' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{purrr}
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
library(purrr)

slow_fcn <- function(x) {
  Sys.sleep(0.1)  # emulate work
  x^2
}

xs <- 1:100
ys <- xs |> map(slow_fcn) |> progressify()
```


# Introduction

This vignette demonstrates how to use this approach to add progress
reporting to **[purrr]** functions such as `map()`, `map_dbl()`, and
`walk()`.

The **purrr** `map()` function is commonly used to apply a function to
the elements of a vector or a list. For example,

```r
library(purrr)
xs <- 1:100
ys <- map(xs, slow_fcn)
```

or equivalently using pipe syntax

```r
xs <- 1:100
ys <- xs |> map(slow_fcn)
```

Here `map()` provides no feedback on how far it has progressed,
but we can easily add progress reporting, by using:

```r
library(purrr)

library(progressify)
handlers(global = TRUE)

xs <- 1:100
ys <- xs |> map(slow_fcn) |> progressify()
```

Using the default progress handler, the progress reporting will
appear as:

```plain
  |=====                    |  20%
```


# Supported Functions

The `progressify()` function supports the following **purrr** functions:

 * `map()`, `map_chr()`, `map_dbl()`, `map_int()`, `map_lgl()`, `map_vec()`, `walk()`
 * `map2()`, `map2_chr()`, `map2_dbl()`, `map2_int()`, `map2_lgl()`, `map2_vec()`, `walk2()`
 * `pmap()`, `pmap_chr()`, `pmap_dbl()`, `pmap_int()`, `pmap_lgl()`, `pmap_vec()`, `pwalk()`
 * `imap()`, `imap_chr()`, `imap_dbl()`, `imap_int()`, `imap_lgl()`
 * `modify()`, `modify2()`, `imodify()`


[purrr]: https://cran.r-project.org/package=purrr
