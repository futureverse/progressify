# Progress updates for 'tm' functions

The **progressify** package allows you to easily add progress reporting
to sequential and parallel map-reduce code by piping to the
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function. Easy!

## TL;DR

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`progressify`](https://progressify.futureverse.org)`)`\
[`handlers`](https://progressr.futureverse.org/reference/handlers.html)`(``global ``=`` ``TRUE``)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`tm`](https://tm.r-forge.r-project.org/)`)`\
\
[`data`](https://rdrr.io/r/utils/data.html)`(``"crude"``, package ``=`` ``"tm"``)`\
\
`docs`` ``<-`` `[`tm_map`](https://rdrr.io/pkg/tm/man/tm_map.html)`(``crude``, `[`content_transformer`](https://rdrr.io/pkg/tm/man/content_transformer.html)`(``tolower``)``)`` ``|>`` `[`progressify`](https://progressify.futureverse.org/reference/progressify.md)`(``)`\
`tdm`` ``<-`` `[`TermDocumentMatrix`](https://rdrr.io/pkg/tm/man/matrix.html)`(``docs``)`` ``|>`` `[`progressify`](https://progressify.futureverse.org/reference/progressify.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to add progress
reporting to **[tm](https://cran.r-project.org/package=tm)** functions
such as [`tm_map()`](https://rdrr.io/pkg/tm/man/tm_map.html) and
[`TermDocumentMatrix()`](https://rdrr.io/pkg/tm/man/matrix.html).

The **tm** package is a framework for text mining. Its functions process
each document in a corpus. For example,

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`tm`](https://tm.r-forge.r-project.org/)`)`\
[`data`](https://rdrr.io/r/utils/data.html)`(``"crude"``, package ``=`` ``"tm"``)`\
`docs`` ``<-`` `[`tm_map`](https://rdrr.io/pkg/tm/man/tm_map.html)`(``crude``, `[`content_transformer`](https://rdrr.io/pkg/tm/man/content_transformer.html)`(``tolower``)``)`\
`docs`` ``<-`` `[`tm_map`](https://rdrr.io/pkg/tm/man/tm_map.html)`(``docs``, ``removePunctuation``)`\
`tdm`` ``<-`` `[`TermDocumentMatrix`](https://rdrr.io/pkg/tm/man/matrix.html)`(``docs``)`

For large corpora, these steps can take a long time without any feedback
on how far they have progressed. We can easily add progress reporting by
using:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`tm`](https://tm.r-forge.r-project.org/)`)`\
\
[`library`](https://rdrr.io/r/base/library.html)`(`[`progressify`](https://progressify.futureverse.org)`)`\
[`handlers`](https://progressr.futureverse.org/reference/handlers.html)`(``global ``=`` ``TRUE``)`\
\
[`data`](https://rdrr.io/r/utils/data.html)`(``"crude"``, package ``=`` ``"tm"``)`\
`docs`` ``<-`` `[`tm_map`](https://rdrr.io/pkg/tm/man/tm_map.html)`(``crude``, `[`content_transformer`](https://rdrr.io/pkg/tm/man/content_transformer.html)`(``tolower``)``)`` ``|>`` `[`progressify`](https://progressify.futureverse.org/reference/progressify.md)`(``)`\
`docs`` ``<-`` `[`tm_map`](https://rdrr.io/pkg/tm/man/tm_map.html)`(``docs``, ``removePunctuation``)`` ``|>`` `[`progressify`](https://progressify.futureverse.org/reference/progressify.md)`(``)`\
`tdm`` ``<-`` `[`TermDocumentMatrix`](https://rdrr.io/pkg/tm/man/matrix.html)`(``docs``)`` ``|>`` `[`progressify`](https://progressify.futureverse.org/reference/progressify.md)`(``)`

Using the default progress handler, the progress reporting will appear
as:

```
  |=====                    |  20%
```

## Supported Functions

The
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function supports the following **tm** functions:

- [`tm_map()`](https://rdrr.io/pkg/tm/man/tm_map.html) for `VCorpus`
  objects
- [`TermDocumentMatrix()`](https://rdrr.io/pkg/tm/man/matrix.html) and
  [`DocumentTermMatrix()`](https://rdrr.io/pkg/tm/man/matrix.html) for
  `VCorpus` and `PCorpus` objects
- [`tm_index()`](https://rdrr.io/pkg/tm/man/tm_filter.html)

These are the functions that process documents via the **tm**
[`tm_parLapply()`](https://rdrr.io/pkg/tm/man/hpc.html) function. Note
that [`tm_map()`](https://rdrr.io/pkg/tm/man/tm_map.html) with
`lazy = TRUE` defers the processing until the documents are accessed,
which is outside the scope of
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md).
The `SimpleCorpus` objects created by
[`Corpus()`](https://rdrr.io/pkg/tm/man/Corpus.html) for vector sources
are processed without
[`tm_parLapply()`](https://rdrr.io/pkg/tm/man/hpc.html). Use
[`VCorpus()`](https://rdrr.io/pkg/tm/man/VCorpus.html) instead to get
progress updates.

## Limitations

The
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function cannot yet be combined with
[`futurize()`](https://futurize.futureverse.org/reference/futurize.html)
of the **[futurize](https://futurize.futureverse.org)** package for
**tm** functions, because both work by setting the
[`tm_parLapply_engine()`](https://rdrr.io/pkg/tm/man/hpc.html) option,
which only one of them can control. With
`|> progressify() |> futurize()`, the processing is parallel, but there
is no progress reporting. With `|> futurize() |> progressify()`, there
is progress reporting, but the processing is sequential.
