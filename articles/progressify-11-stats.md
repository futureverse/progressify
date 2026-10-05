# Progress updates for 'stats' functions

The **progressify** package allows you to easily add progress reporting
to sequential and parallel map-reduce code by piping to the
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function. Easy!

## TL;DR

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`progressify`](https://progressify.futureverse.org)`)`\
[`handlers`](https://progressr.futureverse.org/reference/handlers.html)`(``global ``=`` ``TRUE``)`\
[`library`](https://rdrr.io/r/base/library.html)`(``stats``)`\
\
`d`` ``<-`` `[`as.dendrogram`](https://rdrr.io/r/stats/dendrogram.html)`(`[`hclust`](https://rdrr.io/r/stats/hclust.html)`(`[`dist`](https://rdrr.io/r/stats/dist.html)`(``USArrests``)``)``)`\
`d2`` ``<-`` `[`dendrapply`](https://rdrr.io/r/stats/dendrapply.html)`(``d``, ``function``(``n``)`` ``{`` `[`Sys.sleep`](https://rdrr.io/r/base/Sys.sleep.html)`(``0.01``)``; ``n`` ``}``)`` ``|>`` `[`progressify`](https://progressify.futureverse.org/reference/progressify.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to add progress
reporting to functions such as
[`dendrapply()`](https://rdrr.io/r/stats/dendrapply.html) in the
**stats** package. For example, consider the
[`dendrapply()`](https://rdrr.io/r/stats/dendrapply.html) function,
which is commonly used to apply a function to the nodes of a dendrogram,
as in:

\
`d`` ``<-`` `[`as.dendrogram`](https://rdrr.io/r/stats/dendrogram.html)`(`[`hclust`](https://rdrr.io/r/stats/hclust.html)`(`[`dist`](https://rdrr.io/r/stats/dist.html)`(``USArrests``)``)``)`\
`d2`` ``<-`` `[`dendrapply`](https://rdrr.io/r/stats/dendrapply.html)`(``d``, ``function``(``n``)`` ``{`` `[`Sys.sleep`](https://rdrr.io/r/base/Sys.sleep.html)`(``0.01``)``; ``n`` ``}``)`

Here [`dendrapply()`](https://rdrr.io/r/stats/dendrapply.html) provides
no feedback on how far it has progressed, but we can easily add progress
reporting by using:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`progressify`](https://progressify.futureverse.org)`)`\
[`handlers`](https://progressr.futureverse.org/reference/handlers.html)`(``global ``=`` ``TRUE``)`\
\
`d2`` ``<-`` `[`dendrapply`](https://rdrr.io/r/stats/dendrapply.html)`(``d``, ``function``(``n``)`` ``{`` `[`Sys.sleep`](https://rdrr.io/r/base/Sys.sleep.html)`(``0.01``)``; ``n`` ``}``)`` ``|>`` `[`progressify`](https://progressify.futureverse.org/reference/progressify.md)`(``)`

Using the default progress handler, the progress reporting will appear
as:

```
  |=====                    |  20%
```

## Supported Functions

The
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function supports the following **stats** package functions:

- [`dendrapply()`](https://rdrr.io/r/stats/dendrapply.html)
