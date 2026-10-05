# Progress updates for 'sandwich' functions

The **progressify** package allows you to easily add progress reporting
to sequential and parallel map-reduce code by piping to the
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function. Easy!

## TL;DR

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`progressify`](https://progressify.futureverse.org)`)`\
[`handlers`](https://progressr.futureverse.org/reference/handlers.html)`(``global ``=`` ``TRUE``)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`sandwich`](https://zeileis.codeberg.page/sandwich/)`)`\
\
`fit`` ``<-`` `[`lm`](https://rdrr.io/r/stats/lm.html)`(``dist`` ``~`` ``speed``, data ``=`` ``cars``)`\
`v`` ``<-`` `[`vcovBS`](https://zeileis.codeberg.page/sandwich/reference/vcovBS.html)`(``fit``, R ``=`` ``100L``)`` ``|>`` `[`progressify`](https://progressify.futureverse.org/reference/progressify.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to add progress
reporting to **[sandwich](https://cran.r-project.org/package=sandwich)**
functions such as
[`vcovBS()`](https://zeileis.codeberg.page/sandwich/reference/vcovBS.html)
and
[`vcovJK()`](https://zeileis.codeberg.page/sandwich/reference/vcovJK.html).

The **sandwich** package provides model-robust standard error estimators
for cross-section, time series, and longitudinal data. Some of these
estimators, specifically the bootstrap and jackknife estimators, are
computationally intensive and can benefit from progress reporting.

For example,
[`vcovBS()`](https://zeileis.codeberg.page/sandwich/reference/vcovBS.html)
computes bootstrapped covariance matrix estimators.

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`sandwich`](https://zeileis.codeberg.page/sandwich/)`)`\
`fit`` ``<-`` `[`lm`](https://rdrr.io/r/stats/lm.html)`(``dist`` ``~`` ``speed``, data ``=`` ``cars``)`\
`v`` ``<-`` `[`vcovBS`](https://zeileis.codeberg.page/sandwich/reference/vcovBS.html)`(``fit``, R ``=`` ``100L``)`

Here
[`vcovBS()`](https://zeileis.codeberg.page/sandwich/reference/vcovBS.html)
provides no feedback on how far it has progressed, but we can easily add
progress reporting by using:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`sandwich`](https://zeileis.codeberg.page/sandwich/)`)`\
\
[`library`](https://rdrr.io/r/base/library.html)`(`[`progressify`](https://progressify.futureverse.org)`)`\
[`handlers`](https://progressr.futureverse.org/reference/handlers.html)`(``global ``=`` ``TRUE``)`\
\
`fit`` ``<-`` `[`lm`](https://rdrr.io/r/stats/lm.html)`(``dist`` ``~`` ``speed``, data ``=`` ``cars``)`\
`v`` ``<-`` `[`vcovBS`](https://zeileis.codeberg.page/sandwich/reference/vcovBS.html)`(``fit``, R ``=`` ``100L``)`` ``|>`` `[`progressify`](https://progressify.futureverse.org/reference/progressify.md)`(``)`

Similarly, the jackknife estimator
[`vcovJK()`](https://zeileis.codeberg.page/sandwich/reference/vcovJK.html)
can be progressified:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`sandwich`](https://zeileis.codeberg.page/sandwich/)`)`\
\
[`library`](https://rdrr.io/r/base/library.html)`(`[`progressify`](https://progressify.futureverse.org)`)`\
[`handlers`](https://progressr.futureverse.org/reference/handlers.html)`(``global ``=`` ``TRUE``)`\
\
`fit`` ``<-`` `[`lm`](https://rdrr.io/r/stats/lm.html)`(``dist`` ``~`` ``speed``, data ``=`` ``cars``)`\
`v`` ``<-`` `[`vcovJK`](https://zeileis.codeberg.page/sandwich/reference/vcovJK.html)`(``fit``)`` ``|>`` `[`progressify`](https://progressify.futureverse.org/reference/progressify.md)`(``)`

## Supported Functions

The
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function supports the following **sandwich** functions:

- [`vcovBS()`](https://zeileis.codeberg.page/sandwich/reference/vcovBS.html)
- [`vcovJK()`](https://zeileis.codeberg.page/sandwich/reference/vcovJK.html)
