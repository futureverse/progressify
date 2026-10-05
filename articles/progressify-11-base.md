# Progress updates for base-R apply functions

The **progressify** package allows you to easily add progress reporting
to sequential and parallel map-reduce code by piping to the
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function. Easy!

## TL;DR

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`progressify`](https://progressify.futureverse.org)`)`\
[`handlers`](https://progressr.futureverse.org/reference/handlers.html)`(``global ``=`` ``TRUE``)`\
\
`slow_fcn`` ``<-`` ``function``(``x``)`` ``{`\
`  `[`Sys.sleep`](https://rdrr.io/r/base/Sys.sleep.html)`(``0.1``)``  ``# emulate work`\
`  ``x``^``2`\
`}`\
\
`xs`` ``<-`` ``1``:``100`\
`ys`` ``<-`` `[`lapply`](https://rdrr.io/r/base/lapply.html)`(``xs``, ``slow_fcn``)`` ``|>`` `[`progressify`](https://progressify.futureverse.org/reference/progressify.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to add progress
reporting to functions such as
[`lapply()`](https://rdrr.io/r/base/lapply.html),
[`tapply()`](https://rdrr.io/r/base/tapply.html),
[`apply()`](https://rdrr.io/r/base/apply.html), and
[`replicate()`](https://rdrr.io/r/base/lapply.html) in the **base**
package. For example, consider the base R
[`lapply()`](https://rdrr.io/r/base/lapply.html) function, which is
commonly used to apply a function to the elements of a vector or a list,
as in:

\
`xs`` ``<-`` ``1``:``100`\
`ys`` ``<-`` `[`lapply`](https://rdrr.io/r/base/lapply.html)`(``xs``, ``slow_fcn``)`

Here [`lapply()`](https://rdrr.io/r/base/lapply.html) provides no
feedback on how far it has progressed, but we can easily add progress
reporting by using:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`progressify`](https://progressify.futureverse.org)`)`\
[`handlers`](https://progressr.futureverse.org/reference/handlers.html)`(``global ``=`` ``TRUE``)`\
\
`ys`` ``<-`` `[`lapply`](https://rdrr.io/r/base/lapply.html)`(``xs``, ``slow_fcn``)`` ``|>`` `[`progressify`](https://progressify.futureverse.org/reference/progressify.md)`(``)`

Using the default progress handler, the progress reporting will appear
as:

```
  |=====                    |  20%
```

## Supported Functions

The
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function supports the following **base** package functions:

- [`lapply()`](https://rdrr.io/r/base/lapply.html),
  [`vapply()`](https://rdrr.io/r/base/lapply.html),
  [`sapply()`](https://rdrr.io/r/base/lapply.html)
- [`mapply()`](https://rdrr.io/r/base/mapply.html),
  [`.mapply()`](https://rdrr.io/r/base/mapply.html),
  [`Map()`](https://rdrr.io/r/base/funprog.html)
- [`eapply()`](https://rdrr.io/r/base/eapply.html)
- [`apply()`](https://rdrr.io/r/base/apply.html)
- [`replicate()`](https://rdrr.io/r/base/lapply.html)
- [`by()`](https://rdrr.io/r/base/by.html),
  [`tapply()`](https://rdrr.io/r/base/tapply.html)

## Combining with futurize

The **progressify** package works together with the
**[futurize](https://cran.r-project.org/package=futurize)** package. You
can both parallelize and add progress reporting in a single pipeline:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`progressify`](https://progressify.futureverse.org)`)`\
[`handlers`](https://progressr.futureverse.org/reference/handlers.html)`(``global ``=`` ``TRUE``)`\
\
`xs`` ``<-`` ``1``:``100`\
`ys`` ``<-`` `[`lapply`](https://rdrr.io/r/base/lapply.html)`(``xs``, ``slow_fcn``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.html)`(``)`` ``|>`` `[`progressify`](https://progressify.futureverse.org/reference/progressify.md)`(``)`

## Known issues

The
**[BiocGenerics](https://www.bioconductor.org/packages/BiocGenerics/)**
package defines generic functions
[`lapply()`](https://rdrr.io/r/base/lapply.html),
[`sapply()`](https://rdrr.io/r/base/lapply.html),
[`mapply()`](https://rdrr.io/r/base/mapply.html), and
[`tapply()`](https://rdrr.io/r/base/tapply.html). These S4 generic
functions override the non-generic, counterpart functions in the
**base** package. If **BiocGenerics** is attached, the solution is to
specify that it is the **base** version we wish to progressify, i.e.

\
`y`` ``<-`` ``base``::`[`lapply`](https://rdrr.io/r/base/lapply.html)`(``1``:``3``, ``sqrt``)`` ``|>`` `[`progressify`](https://progressify.futureverse.org/reference/progressify.md)`(``)`
