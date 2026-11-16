<!--
%\VignetteIndexEntry{Progress updates for 'car' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{car}
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
library(car)

fit <- lm(mpg ~ wt + hp, data = mtcars)
res <- Boot(fit, R = 999) |> progressify()
```


# Introduction

This vignette demonstrates how to use this approach to add progress
reporting to **[car]** functions such as `Boot()`.

The **car** `Boot()` function bootstraps regression models, such as
`lm()`, `glm()`, and `nls()` fits. It refits the model `R` times on
resampled data, and collects the statistics of interest from each
refit. For example,

```r
library(car)
fit <- lm(mpg ~ wt + hp, data = mtcars)
res <- Boot(fit, R = 999)
```

Here `Boot()` provides no feedback on how far it has progressed, but
we can easily add progress reporting by using:

```r
library(car)

library(progressify)
handlers(global = TRUE)

fit <- lm(mpg ~ wt + hp, data = mtcars)
res <- Boot(fit, R = 999) |> progressify()
```

Using the default progress handler, the progress reporting will
appear as:

```plain
  |=====                    |  20%
```


# Supported Functions

The `progressify()` function supports the following **car**
functions:

 * `Boot()`


# Limitations

There are no progress updates when `Boot()` processes the bootstrap
replicates in parallel via its `ncores` argument. A bootstrap replicate
for which the refitted model is rank deficient does not report on
progress, so the progress might not reach 100% until `Boot()` is done.


[car]: https://cran.r-project.org/package=car
