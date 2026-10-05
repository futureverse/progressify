# Progress updates for 'foreach' functions

The **progressify** package allows you to easily add progress reporting
to sequential and parallel map-reduce code by piping to the
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function. Easy!

## TL;DR

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`progressify`](https://progressify.futureverse.org)`)`\
[`handlers`](https://progressr.futureverse.org/reference/handlers.html)`(``global ``=`` ``TRUE``)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`foreach`](https://github.com/RevolutionAnalytics/foreach)`)`\
\
`slow_fcn`` ``<-`` ``function``(``x``)`` ``{`\
`  `[`Sys.sleep`](https://rdrr.io/r/base/Sys.sleep.html)`(``0.1``)``  ``# emulate work`\
`  ``x``^``2`\
`}`\
\
`xs`` ``<-`` ``1``:``100`\
`ys`` ``<-`` `[`foreach`](https://rdrr.io/pkg/foreach/man/foreach.html)`(``x ``=`` ``xs``)`` `[`%do%`](https://rdrr.io/pkg/foreach/man/foreach.html)` ``slow_fcn``(``x``)`` ``|>`` `[`progressify`](https://progressify.futureverse.org/reference/progressify.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to add progress
reporting to the
**[foreach](https://cran.r-project.org/package=foreach)**
[`foreach()`](https://rdrr.io/pkg/foreach/man/foreach.html) construct
and the **[doFuture](https://cran.r-project.org/package=doFuture)**
`%dofuture%` operator.

For example, consider:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`foreach`](https://github.com/RevolutionAnalytics/foreach)`)`\
`xs`` ``<-`` ``1``:``100`\
`ys`` ``<-`` `[`foreach`](https://rdrr.io/pkg/foreach/man/foreach.html)`(``x ``=`` ``xs``)`` `[`%do%`](https://rdrr.io/pkg/foreach/man/foreach.html)` ``slow_fcn``(``x``)`

This [`foreach()`](https://rdrr.io/pkg/foreach/man/foreach.html)
construct provides no feedback on how far it has progressed. We can
easily add progress reporting by piping to
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md):

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`foreach`](https://github.com/RevolutionAnalytics/foreach)`)`\
\
[`library`](https://rdrr.io/r/base/library.html)`(`[`progressify`](https://progressify.futureverse.org)`)`\
[`handlers`](https://progressr.futureverse.org/reference/handlers.html)`(``global ``=`` ``TRUE``)`\
\
`xs`` ``<-`` ``1``:``100`\
`ys`` ``<-`` `[`foreach`](https://rdrr.io/pkg/foreach/man/foreach.html)`(``x ``=`` ``xs``)`` `[`%do%`](https://rdrr.io/pkg/foreach/man/foreach.html)` ``slow_fcn``(``x``)`` ``|>`` `[`progressify`](https://progressify.futureverse.org/reference/progressify.md)`(``)`

Using the default progress handler, the progress reporting will appear
as:

```
  |=====                    |  20%
```

### With doFuture

The same approach works with the
**[doFuture](https://cran.r-project.org/package=doFuture)** package for
parallel foreach evaluation:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`doFuture`](https://doFuture.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`\
\
[`library`](https://rdrr.io/r/base/library.html)`(`[`progressify`](https://progressify.futureverse.org)`)`\
[`handlers`](https://progressr.futureverse.org/reference/handlers.html)`(``global ``=`` ``TRUE``)`\
\
`xs`` ``<-`` ``1``:``100`\
`ys`` ``<-`` `[`foreach`](https://rdrr.io/pkg/foreach/man/foreach.html)`(``x ``=`` ``xs``)`` `[`%dofuture%`](https://doFuture.futureverse.org/reference/grapes-dofuture-grapes.html)` ``slow_fcn``(``x``)`` ``|>`` `[`progressify`](https://progressify.futureverse.org/reference/progressify.md)`(``)`

## Supported Functions

The
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function supports the following **foreach** operators:

- `foreach(...) %do% { ... }`
- `foreach(...) %dopar% { ... }`

and the following **doFuture** operator:

- `foreach(...) %dofuture% { ... }`
