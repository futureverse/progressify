# Progress updates for 'sandwich' functions

The **progressify** package allows you to easily add progress reporting
to sequential and parallel map-reduce code by piping to the
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function. Easy!

## TL;DR

``` r

library(progressify)
handlers(global = TRUE)
library(sandwich)

fit <- lm(dist ~ speed, data = cars)
v <- vcovBS(fit, R = 100L) |> progressify()
```

## Introduction

This vignette demonstrates how to use this approach to add progress
reporting to **[sandwich](https://cran.r-project.org/package=sandwich)**
functions such as
[`vcovBS()`](https://sandwich.R-Forge.R-project.org/reference/vcovBS.html)
and
[`vcovJK()`](https://sandwich.R-Forge.R-project.org/reference/vcovJK.html).

The **sandwich** package provides model-robust standard error estimators
for cross-section, time series, and longitudinal data. Some of these
estimators, specifically the bootstrap and jackknife estimators, are
computationally intensive and can benefit from progress reporting.

For example,
[`vcovBS()`](https://sandwich.R-Forge.R-project.org/reference/vcovBS.html)
computes bootstrapped covariance matrix estimators.

``` r

library(sandwich)
fit <- lm(dist ~ speed, data = cars)
v <- vcovBS(fit, R = 100L)
```

Here
[`vcovBS()`](https://sandwich.R-Forge.R-project.org/reference/vcovBS.html)
provides no feedback on how far it has progressed, but we can easily add
progress reporting by using:

``` r

library(sandwich)

library(progressify)
handlers(global = TRUE)

fit <- lm(dist ~ speed, data = cars)
v <- vcovBS(fit, R = 100L) |> progressify()
```

Similarly, the jackknife estimator
[`vcovJK()`](https://sandwich.R-Forge.R-project.org/reference/vcovJK.html)
can be progressified:

``` r

library(sandwich)

library(progressify)
handlers(global = TRUE)

fit <- lm(dist ~ speed, data = cars)
v <- vcovJK(fit) |> progressify()
```

## Supported Functions

The
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function supports the following **sandwich** functions:

- [`vcovBS()`](https://sandwich.R-Forge.R-project.org/reference/vcovBS.html)
- [`vcovJK()`](https://sandwich.R-Forge.R-project.org/reference/vcovJK.html)
