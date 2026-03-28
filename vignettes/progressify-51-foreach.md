<!--
%\VignetteIndexEntry{Progress updates for 'foreach' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{foreach}
%\VignetteKeyword{doFuture}
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
library(progressr)
handlers(global = TRUE)
library(foreach)

slow_fcn <- function(x) {
  Sys.sleep(0.1)  # emulate work
  x^2
}

xs <- 1:100
ys <- foreach(x = xs) %do% slow_fcn(x) |> progressify()
```


# Introduction

This vignette demonstrates how to use this approach to add progress
reporting to the **[foreach]** `foreach()` construct and the
**[doFuture]** `%dofuture%` operator.

For example, consider:

```r
library(foreach)
xs <- 1:100
ys <- foreach(x = xs) %do% slow_fcn(x)
```

This `foreach()` construct provides no feedback on how far it has
progressed. We can easily add progress reporting by piping to
`progressify()`:

```r
library(foreach)

library(progressify)
library(progressr)
handlers(global = TRUE)

xs <- 1:100
ys <- foreach(x = xs) %do% slow_fcn(x) |> progressify()
```

Using the default progress handler, the progress reporting will
appear as:

```plain
  |=====                    |  20%
```


## With doFuture

The same approach works with the **[doFuture]** package for parallel
foreach evaluation:

```r
library(doFuture)
plan(multisession)

library(progressify)
library(progressr)
handlers(global = TRUE)

xs <- 1:100
ys <- foreach(x = xs) %dofuture% slow_fcn(x) |> progressify()
```


# Supported Functions

The `progressify()` function supports the following **foreach**
operators:

 * `foreach(...) %do% { ... }`
 * `foreach(...) %dopar% { ... }`

and the following **doFuture** operator:

 * `foreach(...) %dofuture% { ... }`


[foreach]: https://cran.r-project.org/package=foreach
[doFuture]: https://cran.r-project.org/package=doFuture
