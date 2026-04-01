# Progress updates for 'stats' functions

The **progressify** package allows you to easily add progress reporting
to sequential and parallel map-reduce code by piping to the
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function. Easy!

## TL;DR

``` r

library(progressify)
handlers(global = TRUE)
library(stats)

d <- as.dendrogram(hclust(dist(USArrests)))
d2 <- dendrapply(d, function(n) { Sys.sleep(0.01); n }) |> progressify()
```

## Introduction

This vignette demonstrates how to use this approach to add progress
reporting to functions such as
[`dendrapply()`](https://rdrr.io/r/stats/dendrapply.html) in the
**stats** package. For example, consider the
[`dendrapply()`](https://rdrr.io/r/stats/dendrapply.html) function,
which is commonly used to apply a function to the nodes of a dendrogram,
as in:

``` r

d <- as.dendrogram(hclust(dist(USArrests)))
d2 <- dendrapply(d, function(n) { Sys.sleep(0.01); n })
```

Here [`dendrapply()`](https://rdrr.io/r/stats/dendrapply.html) provides
no feedback on how far it has progressed, but we can easily add progress
reporting by using:

``` r

library(progressify)
handlers(global = TRUE)

d2 <- dendrapply(d, function(n) { Sys.sleep(0.01); n }) |> progressify()
```

Using the default progress handler, the progress reporting will appear
as:

``` plain
  |=====                    |  20%
```

## Supported Functions

The
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function supports the following **stats** package functions:

- [`dendrapply()`](https://rdrr.io/r/stats/dendrapply.html)
