# Progress updates for 'partykit' functions

The **progressify** package allows you to easily add progress reporting
to sequential and parallel map-reduce code by piping to the
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function. Easy!

## TL;DR

``` r

library(partykit)
library(progressify)
library(progressr)
handlers(global = TRUE)

data("Titanic", package = "datasets")
tt <- as.data.frame(Titanic)

forest <- cforest(Survived ~ ., data = tt, ntree = 50L) |> progressify()
```

## Introduction

This vignette demonstrates how to use this approach to add progress
reporting to **[partykit](https://cran.r-project.org/package=partykit)**
functions such as
[`cforest()`](https://rdrr.io/pkg/partykit/man/cforest.html).

The **partykit**
[`cforest()`](https://rdrr.io/pkg/partykit/man/cforest.html) function is
an implementation of random forests. For example,

``` r

library(partykit)
data("Titanic", package = "datasets")
tt <- as.data.frame(Titanic)
forest <- cforest(Survived ~ ., data = tt, ntree = 50L)
```

Here [`cforest()`](https://rdrr.io/pkg/partykit/man/cforest.html)
provides no feedback on how far it has progressed, but we can easily add
progress reporting, by using:

``` r

library(partykit)

library(progressify)
library(progressr)
handlers(global = TRUE)

data("Titanic", package = "datasets")
tt <- as.data.frame(Titanic)

forest <- cforest(Survived ~ ., data = tt, ntree = 50L) |> progressify()
```

Using the default progress handler, the progress reporting will appear
as:

``` plain
  |=====                    |  20%
```

## Supported Functions

The
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function supports the following **partykit** functions:

- [`cforest()`](https://rdrr.io/pkg/partykit/man/cforest.html)
