# Progress updates for 'partykit' functions

The **progressify** package allows you to easily add progress reporting
to sequential and parallel map-reduce code by piping to the
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function. Easy!

## TL;DR

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`progressify`](https://progressify.futureverse.org)`)`\
[`handlers`](https://progressr.futureverse.org/reference/handlers.html)`(``global ``=`` ``TRUE``)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`partykit`](https://codeberg.org/thothorn/partykit)`)`\
\
[`data`](https://rdrr.io/r/utils/data.html)`(``"Titanic"``, package ``=`` ``"datasets"``)`\
`tt`` ``<-`` `[`as.data.frame`](https://rdrr.io/r/base/as.data.frame.html)`(``Titanic``)`\
\
`forest`` ``<-`` `[`cforest`](https://rdrr.io/pkg/partykit/man/cforest.html)`(``Survived`` ``~`` ``.``, data ``=`` ``tt``, ntree ``=`` ``50L``)`` ``|>`` `[`progressify`](https://progressify.futureverse.org/reference/progressify.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to add progress
reporting to **[partykit](https://cran.r-project.org/package=partykit)**
functions such as
[`cforest()`](https://rdrr.io/pkg/partykit/man/cforest.html).

The **partykit**
[`cforest()`](https://rdrr.io/pkg/partykit/man/cforest.html) function is
an implementation of random forests. For example,

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`partykit`](https://codeberg.org/thothorn/partykit)`)`\
[`data`](https://rdrr.io/r/utils/data.html)`(``"Titanic"``, package ``=`` ``"datasets"``)`\
`tt`` ``<-`` `[`as.data.frame`](https://rdrr.io/r/base/as.data.frame.html)`(``Titanic``)`\
`forest`` ``<-`` `[`cforest`](https://rdrr.io/pkg/partykit/man/cforest.html)`(``Survived`` ``~`` ``.``, data ``=`` ``tt``, ntree ``=`` ``50L``)`

Here [`cforest()`](https://rdrr.io/pkg/partykit/man/cforest.html)
provides no feedback on how far it has progressed, but we can easily add
progress reporting by using:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`partykit`](https://codeberg.org/thothorn/partykit)`)`\
\
[`library`](https://rdrr.io/r/base/library.html)`(`[`progressify`](https://progressify.futureverse.org)`)`\
[`handlers`](https://progressr.futureverse.org/reference/handlers.html)`(``global ``=`` ``TRUE``)`\
\
[`data`](https://rdrr.io/r/utils/data.html)`(``"Titanic"``, package ``=`` ``"datasets"``)`\
`tt`` ``<-`` `[`as.data.frame`](https://rdrr.io/r/base/as.data.frame.html)`(``Titanic``)`\
\
`forest`` ``<-`` `[`cforest`](https://rdrr.io/pkg/partykit/man/cforest.html)`(``Survived`` ``~`` ``.``, data ``=`` ``tt``, ntree ``=`` ``50L``)`` ``|>`` `[`progressify`](https://progressify.futureverse.org/reference/progressify.md)`(``)`

Using the default progress handler, the progress reporting will appear
as:

```
  |=====                    |  20%
```

## Supported Functions

The
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function supports the following **partykit** functions:

- [`cforest()`](https://rdrr.io/pkg/partykit/man/cforest.html)
