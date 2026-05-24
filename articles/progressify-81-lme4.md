# Progress updates for 'lme4' functions

The **progressify** package allows you to easily add progress reporting
to sequential and parallel map-reduce code by piping to the
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function. Easy!

## TL;DR

``` r

library(progressify)
handlers(global = TRUE)
library(lme4)

# Fit random-slope model
fm1 <- lmer(Reaction ~ Days + (Days | Subject), sleepstudy)
my_stat <- function(fit) {
  fixef(fit)
}

# Run bootstrap with progress signaling
res <- bootMer(fm1, my_stat, nsim = 1000) |> progressify()
```

## Introduction

This vignette demonstrates how to use this approach to add progress
reporting to **[lme4](https://cran.r-project.org/package=lme4)**
functions such as
[`bootMer()`](https://rdrr.io/pkg/lme4/man/bootMer.html). The **lme4**
package provides functions for fitting linear, generalized linear, and
nonlinear mixed-effects models. For example,
[`bootMer()`](https://rdrr.io/pkg/lme4/man/bootMer.html) runs a
statistic function `nsim` times:

``` r

library(lme4)

# Fit random-slope model
fm1 <- lmer(Reaction ~ Days + (Days | Subject), sleepstudy)
my_stat <- function(fit) {
  fixef(fit)
}

res <- bootMer(fm1, my_stat, nsim = 1000)
```

By default, [`bootMer()`](https://rdrr.io/pkg/lme4/man/bootMer.html)
provides no progress feedback. However, we can easily add progress
reporting using the
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function:

``` r

library(lme4)
library(progressify)
handlers(global = TRUE)

# Fit random-slope model
fm1 <- lmer(Reaction ~ Days + (Days | Subject), sleepstudy)
my_stat <- function(fit) {
  fixef(fit)
}

res <- bootMer(fm1, my_stat, nsim = 1000) |> progressify()
```

## Supported Functions

The
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function supports the following **lme4** functions:

- [`bootMer()`](https://rdrr.io/pkg/lme4/man/bootMer.html)
