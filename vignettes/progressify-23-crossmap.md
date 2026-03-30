<!--
%\VignetteIndexEntry{Progress updates for 'crossmap' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{crossmap}
%\VignetteKeyword{vignette}
%\VignetteKeyword{progressify}
%\VignetteEngine{progressify::selfonly}
-->

The **progressify** package allows you to easily add progress
reporting to sequential and parallel map-reduce code by piping to the
`progressify()` function. Easy!


# TL;DR

```r
library(crossmap)
library(progressify)
library(progressr)
handlers(global = TRUE)

slow_fcn <- function(x, y) {
  Sys.sleep(0.1)  # emulate work
  x * y
}

xs <- list(1:5, 1:5)
ys <- xmap(xs, slow_fcn) |> progressify()
```


# Introduction

This vignette demonstrates how to use this approach to add progress
reporting to **[crossmap]** functions such as `xmap()`.

The **crossmap** package extends **purrr** with functions that apply
a function to every combination of elements in a list of inputs.
For example, `xmap()` computes the cross product of its inputs:

```r
library(crossmap)
xs <- list(1:5, 1:5)
ys <- xmap(xs, slow_fcn)
```

Here `xmap()` provides no feedback on how far it has progressed,
but we can easily add progress reporting, by using:

```r
library(crossmap)

library(progressify)
library(progressr)
handlers(global = TRUE)

xs <- list(1:5, 1:5)
ys <- xmap(xs, slow_fcn) |> progressify()
```

Using the default progress handler, the progress reporting will
appear as:

```plain
  |=====                    |  20%
```


# Supported Functions

The `progressify()` function supports the following **crossmap**
functions:

 * `xmap()` and variants (`xmap_chr()`, `xmap_dbl()`, `xmap_int()`,
   `xmap_lgl()`, `xmap_vec()`, `xmap_dfc()`, `xmap_dfr()`,
   `xmap_mat()`, `xmap_arr()`)
 * `xwalk()`
 * `map_vec()`, `map2_vec()`, `pmap_vec()`, `imap_vec()`


[crossmap]: https://cran.r-project.org/package=crossmap
