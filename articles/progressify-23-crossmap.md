# Progress updates for 'crossmap' functions

The **progressify** package allows you to easily add progress reporting
to sequential and parallel map-reduce code by piping to the
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function. Easy!

## TL;DR

``` r

library(crossmap)
library(progressify)
handlers(global = TRUE)

slow_fcn <- function(x, y) {
  Sys.sleep(0.1)  # emulate work
  x * y
}

xs <- list(1:5, 1:5)
ys <- xmap(xs, slow_fcn) |> progressify()
```

## Introduction

This vignette demonstrates how to use this approach to add progress
reporting to **[crossmap](https://cran.r-project.org/package=crossmap)**
functions such as
[`xmap()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html).

The **crossmap** package extends **purrr** with functions that apply a
function to every combination of elements in a list of inputs. For
example,
[`xmap()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html)
computes the cross product of its inputs:

``` r

library(crossmap)
xs <- list(1:5, 1:5)
ys <- xmap(xs, slow_fcn)
```

Here
[`xmap()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html)
provides no feedback on how far it has progressed, but we can easily add
progress reporting, by using:

``` r

library(crossmap)

library(progressify)
handlers(global = TRUE)

xs <- list(1:5, 1:5)
ys <- xmap(xs, slow_fcn) |> progressify()
```

Using the default progress handler, the progress reporting will appear
as:

``` plain
  |=====                    |  20%
```

## Supported Functions

The
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function supports the following **crossmap** functions:

- [`xmap()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html)
  and variants
  ([`xmap_chr()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html),
  [`xmap_dbl()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html),
  [`xmap_int()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html),
  [`xmap_lgl()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html),
  [`xmap_vec()`](https://pkg.rossellhayes.com/crossmap/reference/map_vec.html),
  [`xmap_dfc()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html),
  [`xmap_dfr()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html),
  [`xmap_mat()`](https://pkg.rossellhayes.com/crossmap/reference/xmap_mat.html),
  [`xmap_arr()`](https://pkg.rossellhayes.com/crossmap/reference/xmap_mat.html))
- [`xwalk()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html)
- [`map_vec()`](https://pkg.rossellhayes.com/crossmap/reference/map_vec.html),
  [`map2_vec()`](https://pkg.rossellhayes.com/crossmap/reference/map_vec.html),
  [`pmap_vec()`](https://pkg.rossellhayes.com/crossmap/reference/map_vec.html),
  [`imap_vec()`](https://pkg.rossellhayes.com/crossmap/reference/map_vec.html)
