# Progress updates for 'car' functions

The **progressify** package allows you to easily add progress reporting
to sequential and parallel map-reduce code by piping to the
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function. Easy!

## TL;DR

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`progressify`](https://progressify.futureverse.org)`)`\
[`handlers`](https://progressr.futureverse.org/reference/handlers.html)`(``global ``=`` ``TRUE``)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`car`](https://github.com/bprice2652/car_repo)`)`\
\
`fit`` ``<-`` `[`lm`](https://rdrr.io/r/stats/lm.html)`(``mpg`` ``~`` ``wt`` ``+`` ``hp``, data ``=`` ``mtcars``)`\
`res`` ``<-`` `[`Boot`](https://rdrr.io/pkg/car/man/Boot.html)`(``fit``, R ``=`` ``999``)`` ``|>`` `[`progressify`](https://progressify.futureverse.org/reference/progressify.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to add progress
reporting to **[car](https://cran.r-project.org/package=car)** functions
such as [`Boot()`](https://rdrr.io/pkg/car/man/Boot.html).

The **car** [`Boot()`](https://rdrr.io/pkg/car/man/Boot.html) function
bootstraps regression models, such as
[`lm()`](https://rdrr.io/r/stats/lm.html),
[`glm()`](https://rdrr.io/r/stats/glm.html), and
[`nls()`](https://rdrr.io/r/stats/nls.html) fits. It refits the model
`R` times on resampled data, and collects the statistics of interest
from each refit. For example,

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`car`](https://github.com/bprice2652/car_repo)`)`\
`fit`` ``<-`` `[`lm`](https://rdrr.io/r/stats/lm.html)`(``mpg`` ``~`` ``wt`` ``+`` ``hp``, data ``=`` ``mtcars``)`\
`res`` ``<-`` `[`Boot`](https://rdrr.io/pkg/car/man/Boot.html)`(``fit``, R ``=`` ``999``)`

Here [`Boot()`](https://rdrr.io/pkg/car/man/Boot.html) provides no
feedback on how far it has progressed, but we can easily add progress
reporting by using:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`car`](https://github.com/bprice2652/car_repo)`)`\
\
[`library`](https://rdrr.io/r/base/library.html)`(`[`progressify`](https://progressify.futureverse.org)`)`\
[`handlers`](https://progressr.futureverse.org/reference/handlers.html)`(``global ``=`` ``TRUE``)`\
\
`fit`` ``<-`` `[`lm`](https://rdrr.io/r/stats/lm.html)`(``mpg`` ``~`` ``wt`` ``+`` ``hp``, data ``=`` ``mtcars``)`\
`res`` ``<-`` `[`Boot`](https://rdrr.io/pkg/car/man/Boot.html)`(``fit``, R ``=`` ``999``)`` ``|>`` `[`progressify`](https://progressify.futureverse.org/reference/progressify.md)`(``)`

Using the default progress handler, the progress reporting will appear
as:

```
  |=====                    |  20%
```

## Supported Functions

The
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function supports the following **car** functions:

- [`Boot()`](https://rdrr.io/pkg/car/man/Boot.html)

## Limitations

There are no progress updates when
[`Boot()`](https://rdrr.io/pkg/car/man/Boot.html) processes the
bootstrap replicates in parallel via its `ncores` argument. A bootstrap
replicate for which the refitted model is rank deficient does not report
on progress, so the progress might not reach 100% until
[`Boot()`](https://rdrr.io/pkg/car/man/Boot.html) is done.
