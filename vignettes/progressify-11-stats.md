<!--
%\VignetteIndexEntry{Progress updates for 'stats' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{stats}
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

d <- as.dendrogram(hclust(dist(USArrests)))
d2 <- dendrapply(d, function(n) { Sys.sleep(0.01); n }) |> progressify()
```


# Introduction

This vignette demonstrates how to use this approach to add progress
reporting to functions such as `dendrapply()` in the **stats**
package. For example, consider the `dendrapply()` function, which is
commonly used to apply a function to the nodes of a dendrogram, as in:

```r
d <- as.dendrogram(hclust(dist(USArrests)))
d2 <- dendrapply(d, function(n) { Sys.sleep(0.01); n })
```

Here `dendrapply()` provides no feedback on how far it has
progressed, but we can easily add progress reporting, by using:

```r
library(progressify)
handlers(global = TRUE)

d2 <- dendrapply(d, function(n) { Sys.sleep(0.01); n }) |> progressify()
```

Using the default progress handler, the progress reporting will
appear as:

```plain
  |=====                    |  20%
```


# Supported Functions

The `progressify()` function supports the following **stats** package
functions:

 * `dendrapply()`
