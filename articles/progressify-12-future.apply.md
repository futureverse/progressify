# Progress updates for 'future.apply' functions

The **progressify** package allows you to easily add progress reporting
to sequential and parallel map-reduce code by piping to the
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function. Easy!

## TL;DR

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`progressify`](https://progressify.futureverse.org)`)`\
[`handlers`](https://progressr.futureverse.org/reference/handlers.html)`(``global ``=`` ``TRUE``)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`future.apply`](https://future.apply.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`\
\
`slow_fcn`` ``<-`` ``function``(``x``)`` ``{`\
`  `[`Sys.sleep`](https://rdrr.io/r/base/Sys.sleep.html)`(``0.1``)``  ``# emulate work`\
`  ``x``^``2`\
`}`\
\
`xs`` ``<-`` ``1``:``100`\
`ys`` ``<-`` `[`future_lapply`](https://future.apply.futureverse.org/reference/future_lapply.html)`(``xs``, ``slow_fcn``)`` ``|>`` `[`progressify`](https://progressify.futureverse.org/reference/progressify.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to add progress
reporting to
**[future.apply](https://cran.r-project.org/package=future.apply)**
functions such as
[`future_lapply()`](https://future.apply.futureverse.org/reference/future_lapply.html),
[`future_tapply()`](https://future.apply.futureverse.org/reference/future_lapply.html),
[`future_apply()`](https://future.apply.futureverse.org/reference/future_apply.html),
and
[`future_replicate()`](https://future.apply.futureverse.org/reference/future_lapply.html).

The **future.apply**
[`future_lapply()`](https://future.apply.futureverse.org/reference/future_lapply.html)
function is commonly used to apply a function to the elements of a
vector or a list in parallel. For example,

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`future.apply`](https://future.apply.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`\
\
`xs`` ``<-`` ``1``:``100`\
`ys`` ``<-`` `[`future_lapply`](https://future.apply.futureverse.org/reference/future_lapply.html)`(``xs``, ``slow_fcn``)`

Here
[`future_lapply()`](https://future.apply.futureverse.org/reference/future_lapply.html)
provides no feedback on how far it has progressed, but we can easily add
progress reporting by using:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`future.apply`](https://future.apply.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`\
\
[`library`](https://rdrr.io/r/base/library.html)`(`[`progressify`](https://progressify.futureverse.org)`)`\
[`handlers`](https://progressr.futureverse.org/reference/handlers.html)`(``global ``=`` ``TRUE``)`\
\
`ys`` ``<-`` `[`future_lapply`](https://future.apply.futureverse.org/reference/future_lapply.html)`(``xs``, ``slow_fcn``)`` ``|>`` `[`progressify`](https://progressify.futureverse.org/reference/progressify.md)`(``)`

Using the default progress handler, the progress reporting will appear
as:

```
  |=====                    |  20%
```

## Supported Functions

The
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function supports the following **future.apply** functions:

- [`future_lapply()`](https://future.apply.futureverse.org/reference/future_lapply.html),
  [`future_vapply()`](https://future.apply.futureverse.org/reference/future_lapply.html),
  [`future_sapply()`](https://future.apply.futureverse.org/reference/future_lapply.html),
  [`future_tapply()`](https://future.apply.futureverse.org/reference/future_lapply.html)
- [`future_mapply()`](https://future.apply.futureverse.org/reference/future_mapply.html),
  [`future_.mapply()`](https://future.apply.futureverse.org/reference/future_mapply.html),
  [`future_Map()`](https://future.apply.futureverse.org/reference/future_mapply.html)
- [`future_eapply()`](https://future.apply.futureverse.org/reference/future_lapply.html)
- [`future_apply()`](https://future.apply.futureverse.org/reference/future_apply.html)
- [`future_replicate()`](https://future.apply.futureverse.org/reference/future_lapply.html)
- [`future_by()`](https://future.apply.futureverse.org/reference/future_by.html)
