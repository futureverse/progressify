<!--
%\VignetteIndexEntry{Progress updates for 'plyr' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{plyr}
%\VignetteKeyword{vignette}
%\VignetteKeyword{progressify}
%\VignetteEngine{progressify::selfonly}
-->

The **progressify** package allows you to easily add progress
reporting to sequential and parallel map-reduce code by piping to the
`progressify()` function. Easy!


# TL;DR

```r
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


# Introduction

This vignette demonstrates how to use this approach to add progress
reporting to **[plyr]** functions such as `llply()`, `maply()`, and
`ddply()`.

The **plyr** `llply()` function is commonly used to apply a function
to the elements of a list and return a list. For example,

```r
library(plyr)
xs <- 1:100
ys <- llply(xs, slow_fcn)
```

Here `llply()` provides no feedback on how far it has progressed,
but we can easily add progress reporting, by using:

```r
library(plyr)

library(progressify)
handlers(global = TRUE)

xs <- 1:100
ys <- llply(xs, slow_fcn) |> progressify()
```

Using the default progress handler, the progress reporting will
appear as:

```plain
  |=====                    |  20%
```


# Supported Functions

The `progressify()` function supports the following **plyr**
functions:

 * `l_ply()`, `laply()`, `ldply()`, `llply()`
 * `m_ply()`, `maply()`, `mdply()`, `mlply()`
 * `r_ply()`, `raply()`, `rdply()`, `rlply()`


[plyr]: https://cran.r-project.org/package=plyr
