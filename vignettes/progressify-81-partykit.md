<!--
%\VignetteIndexEntry{Progress updates for 'partykit' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{partykit}
%\VignetteKeyword{vignette}
%\VignetteKeyword{progressify}
%\VignetteEngine{progressify::selfonly}
-->

The **progressify** package allows you to easily add progress
reporting to sequential and parallel map-reduce code by piping to the
`progressify()` function. Easy!


# TL;DR

```r
library(partykit)
library(progressify)
handlers(global = TRUE)

data("Titanic", package = "datasets")
tt <- as.data.frame(Titanic)

forest <- cforest(Survived ~ ., data = tt, ntree = 50L) |> progressify()
```


# Introduction

This vignette demonstrates how to use this approach to add progress
reporting to **[partykit]** functions such as `cforest()`.

The **partykit** `cforest()` function is an implementation of random
forests. For example,

```r
library(partykit)
data("Titanic", package = "datasets")
tt <- as.data.frame(Titanic)
forest <- cforest(Survived ~ ., data = tt, ntree = 50L)
```

Here `cforest()` provides no feedback on how far it has progressed,
but we can easily add progress reporting, by using:

```r
library(partykit)

library(progressify)
handlers(global = TRUE)

data("Titanic", package = "datasets")
tt <- as.data.frame(Titanic)

forest <- cforest(Survived ~ ., data = tt, ntree = 50L) |> progressify()
```

Using the default progress handler, the progress reporting will
appear as:

```plain
  |=====                    |  20%
```


# Supported Functions

The `progressify()` function supports the following **partykit**
functions:

 * `cforest()`


[partykit]: https://cran.r-project.org/package=partykit
