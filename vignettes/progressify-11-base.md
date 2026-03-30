<!--
%\VignetteIndexEntry{Progress updates for base-R apply functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
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

slow_fcn <- function(x) {
  Sys.sleep(0.1)  # emulate work
  x^2
}

xs <- 1:100
ys <- lapply(xs, slow_fcn) |> progressify()
```


# Introduction

This vignette demonstrates how to use this approach to add progress
reporting to functions such as `lapply()`, `tapply()`, `apply()`, and
`replicate()` in the **base** package. For example, consider the base
R `lapply()` function, which is commonly used to apply a function to
the elements of a vector or a list, as in:

```r
xs <- 1:100
ys <- lapply(xs, slow_fcn)
```

Here `lapply()` provides no feedback on how far it has progressed,
but we can easily add progress reporting, by using:

```r
library(progressify)
handlers(global = TRUE)

ys <- lapply(xs, slow_fcn) |> progressify()
```

Using the default progress handler, the progress reporting will
appear as:

```plain
  |=====                    |  20%
```


# Supported Functions

The `progressify()` function supports the following **base** package
functions:

 * `lapply()`, `vapply()`, `sapply()`, `tapply()`
 * `mapply()`, `.mapply()`, `Map()`
 * `eapply()`
 * `apply()`
 * `replicate()`
 * `by()`


# Combining with futurize

The **progressify** package works together with the **[futurize]**
package. You can both parallelize and add progress reporting in a
single pipeline:

```r
library(futurize)
plan(multisession)
library(progressify)
handlers(global = TRUE)

xs <- 1:100
ys <- lapply(xs, slow_fcn) |> futurize() |> progressify()
```


# Known issues

The **[BiocGenerics]** package defines generic functions `lapply()`,
`sapply()`, `mapply()`, and `tapply()`. These S4 generic functions
override the non-generic, counterpart functions in the **base**
package. If **BiocGenerics** is attached, the solution is to specify
that it is the **base** version we wish to progressify, i.e.

```r
y <- base::lapply(1:3, sqrt) |> progressify()
```


[futurize]: https://cran.r-project.org/package=futurize
[BiocGenerics]: https://www.bioconductor.org/packages/BiocGenerics/
