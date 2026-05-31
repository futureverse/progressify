<!--
%\VignetteIndexEntry{Progress updates for 'SimDesign' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{SimDesign}
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
library(SimDesign)

# Create small design
Design <- createDesign(factor1 = c(1, 2))

Generate <- function(condition, fixed_objects = NULL) {
  rnorm(100)
}

Analyse <- function(condition, dat, fixed_objects = NULL) {
  mean(dat)
}

Summarise <- function(condition, results, fixed_objects = NULL) {
  mean(results)
}

# Run simulation with progress signaling
res <- runSimulation(design = Design, replications = 100,
                     generate = Generate, analyse = Analyse,
                     summarise = Summarise) |> progressify()
```


# Introduction

This vignette demonstrates how to use this approach to add progress
reporting to **[SimDesign]** functions such as `runSimulation()`.  The
**SimDesign** package provides a comprehensive framework for Monte
Carlo simulation studies in R. For example, `runSimulation()`
evaluates the `generate` and `analyse` functions `replications` times
for each condition in the `design`:

```r
library(SimDesign)

Design <- createDesign(factor1 = c(1, 2))
Generate <- function(condition, fixed_objects = NULL) rnorm(100)
Analyse <- function(condition, dat, fixed_objects = NULL) mean(dat)
Summarise <- function(condition, results, fixed_objects = NULL) mean(results)

res <- runSimulation(design = Design, replications = 100,
                     generate = Generate, analyse = Analyse,
                     summarise = Summarise)
```

By default, `runSimulation()` provides its own text/console-based
progress bar. However, we can easily replace this with
**progressr**-based reporting using the `progressify()` function:

```r
library(SimDesign)
library(progressify)
handlers(global = TRUE)

res <- runSimulation(design = Design, replications = 100,
                     generate = Generate, analyse = Analyse,
                     summarise = Summarise) |> progressify()
```

When progressified, `progressify()` automatically silences
`SimDesign`'s native console progress bar and routes the progress
updates through `progressr`. This means you can use any of the
[supported progressr handlers], e.g., Shiny progress bars, system
notifications, or CLI progress spinners.

# Supported Functions

The `progressify()` function supports the following **SimDesign** functions:

 * `runSimulation()`


[SimDesign]: https://cran.r-project.org/package=SimDesign
[supported progressr handlers]: https://progressr.futureverse.org/articles/progressr-11-handlers.html
