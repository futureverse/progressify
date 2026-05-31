<!--
%\VignetteIndexEntry{Progress updates for 'sandwich' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{sandwich}
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
library(sandwich)

fit <- lm(dist ~ speed, data = cars)
v <- vcovBS(fit, R = 100L) |> progressify()
```


# Introduction

This vignette demonstrates how to use this approach to add progress
reporting to **[sandwich]** functions such as `vcovBS()` and `vcovJK()`.

The **sandwich** package provides model-robust standard error
estimators for cross-section, time series, and longitudinal data.
Some of these estimators, specifically the bootstrap and jackknife
estimators, are computationally intensive and can benefit from
progress reporting.

For example, `vcovBS()` computes bootstrapped covariance matrix
estimators.

```r
library(sandwich)
fit <- lm(dist ~ speed, data = cars)
v <- vcovBS(fit, R = 100L)
```

Here `vcovBS()` provides no feedback on how far it has progressed,
but we can easily add progress reporting by using:

```r
library(sandwich)

library(progressify)
handlers(global = TRUE)

fit <- lm(dist ~ speed, data = cars)
v <- vcovBS(fit, R = 100L) |> progressify()
```

Similarly, the jackknife estimator `vcovJK()` can be progressified:

```r
library(sandwich)

library(progressify)
handlers(global = TRUE)

fit <- lm(dist ~ speed, data = cars)
v <- vcovJK(fit) |> progressify()
```


# Supported Functions

The `progressify()` function supports the following **sandwich**
functions:

 * `vcovBS()`
 * `vcovJK()`


[sandwich]: https://cran.r-project.org/package=sandwich
