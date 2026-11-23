<!--
%\VignetteIndexEntry{Progress updates for 'tm' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{tm}
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
library(tm)

data("crude", package = "tm")

docs <- tm_map(crude, content_transformer(tolower)) |> progressify()
tdm <- TermDocumentMatrix(docs) |> progressify()
```


# Introduction

This vignette demonstrates how to use this approach to add progress
reporting to **[tm]** functions such as `tm_map()` and
`TermDocumentMatrix()`.

The **tm** package is a framework for text mining. Its functions
process each document in a corpus. For example,

```r
library(tm)
data("crude", package = "tm")
docs <- tm_map(crude, content_transformer(tolower))
docs <- tm_map(docs, removePunctuation)
tdm <- TermDocumentMatrix(docs)
```

For large corpora, these steps can take a long time without any
feedback on how far they have progressed. We can easily add progress
reporting by using:

```r
library(tm)

library(progressify)
handlers(global = TRUE)

data("crude", package = "tm")
docs <- tm_map(crude, content_transformer(tolower)) |> progressify()
docs <- tm_map(docs, removePunctuation) |> progressify()
tdm <- TermDocumentMatrix(docs) |> progressify()
```

Using the default progress handler, the progress reporting will
appear as:

```plain
  |=====                    |  20%
```


# Supported Functions

The `progressify()` function supports the following **tm** functions:

 * `tm_map()` for `VCorpus` objects
 * `TermDocumentMatrix()` and `DocumentTermMatrix()` for `VCorpus`
   and `PCorpus` objects
 * `tm_index()`

These are the functions that process documents via the **tm**
`tm_parLapply()` function. Note that `tm_map()` with `lazy = TRUE`
defers the processing until the documents are accessed, which is
outside the scope of `progressify()`. The `SimpleCorpus` objects
created by `Corpus()` for vector sources are processed without
`tm_parLapply()`. Use `VCorpus()` instead to get progress updates.


# Limitations

The `progressify()` function cannot yet be combined with `futurize()`
of the **[futurize]** package for **tm** functions, because both work
by setting the `tm_parLapply_engine()` option, which only one of them
can control. With `|> progressify() |> futurize()`, the processing is
parallel, but there is no progress reporting. With `|> futurize() |>
progressify()`, there is progress reporting, but the processing is
sequential.


[tm]: https://cran.r-project.org/package=tm
[futurize]: https://futurize.futureverse.org
