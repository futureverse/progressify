<!--
%\VignetteIndexEntry{Progress updates for 'Sim.DiffProc' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{Sim.DiffProc}
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
library(Sim.DiffProc)

f <- expression(3 * (1 - x))
g <- expression(0.5)
mod <- snssde1d(drift = f, diffusion = g, x0 = 5, T = 10, M = 50)
stat <- function(data, i) {
  d <- data[i, ]
  c(mean(d), var(d))
}

res <- MCM.sde(mod, statistic = stat, R = 100) |> progressify()
```


# Introduction

This vignette demonstrates how to use this approach to add progress
reporting to **[Sim.DiffProc]** functions such as `MCM.sde()`.

The **Sim.DiffProc** `MCM.sde()` function performs parallel Monte
Carlo estimation of statistics of stochastic differential equations
(SDEs). It simulates the SDE model `R` times, and then calculates the
statistics of interest from these simulations. For example,

```r
library(Sim.DiffProc)

## dX(t) = 3*(1-X(t)) dt + 0.5 * dW(t), X(0)=5, t in [0,10]
f <- expression(3 * (1 - x))
g <- expression(0.5)
mod <- snssde1d(drift = f, diffusion = g, x0 = 5, T = 10, M = 50)

stat <- function(data, i) {
  d <- data[i, ]
  c(mean(d), var(d))
}

res <- MCM.sde(mod, statistic = stat, R = 100)
```

Here `MCM.sde()` provides no feedback on how far it has progressed,
but we can easily add progress reporting by using:

```r
library(Sim.DiffProc)

library(progressify)
handlers(global = TRUE)

res <- MCM.sde(mod, statistic = stat, R = 100) |> progressify()
```

This reports on progress for each of the `R` simulations, which is
where most of the processing time is spent. Using the default progress
handler, the progress reporting will appear as:

```plain
  |=====                    |  20%
```


# Supported Functions

The `progressify()` function supports the following **Sim.DiffProc**
functions:

 * `MCM.sde()`


# Limitations

To combine `progressify()` with `futurize()` of the **[futurize]**
package, which runs the simulations in parallel, use:

```r
library(futurize)
plan(multisession)

res <- MCM.sde(mod, statistic = stat, R = 100) |> futurize() |> progressify()
```

The reverse order, `|> progressify() |> futurize()`, gives an error.
There are no progress updates when `MCM.sde()` parallelizes via its
own `parallel = "multicore"` or `parallel = "snow"` arguments.


[Sim.DiffProc]: https://cran.r-project.org/package=Sim.DiffProc
[futurize]: https://futurize.futureverse.org
