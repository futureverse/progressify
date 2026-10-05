# Progress updates for 'boot' functions

The **progressify** package allows you to easily add progress reporting
to sequential and parallel map-reduce code by piping to the
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function. Easy!

## TL;DR

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`progressify`](https://progressify.futureverse.org)`)`\
[`handlers`](https://progressr.futureverse.org/reference/handlers.html)`(``global ``=`` ``TRUE``)`\
[`library`](https://rdrr.io/r/base/library.html)`(``boot``)`\
\
`# Run bootstrap with progress signaling`\
`x`` ``<-`` ``1``:``100`\
`my_stat`` ``<-`` ``function``(``data``, ``i``)`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``data``[``i``]``)`\
`res`` ``<-`` `[`boot`](https://rdrr.io/pkg/boot/man/boot.html)`(``data ``=`` ``x``, statistic ``=`` ``my_stat``, R ``=`` ``1000``)`` ``|>`` `[`progressify`](https://progressify.futureverse.org/reference/progressify.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to add progress
reporting to **[boot](https://cran.r-project.org/package=boot)**
functions such as [`boot()`](https://rdrr.io/pkg/boot/man/boot.html),
[`censboot()`](https://rdrr.io/pkg/boot/man/censboot.html), and
[`tsboot()`](https://rdrr.io/pkg/boot/man/tsboot.html).

The **boot** package provides functions for generating bootstrap
replicates. Because these computations are iterative and computationally
intensive, they can benefit significantly from progress reporting.

For example, [`boot()`](https://rdrr.io/pkg/boot/man/boot.html) runs a
statistic function `R` times:

\
[`library`](https://rdrr.io/r/base/library.html)`(``boot``)`\
`x`` ``<-`` ``1``:``100`\
`my_stat`` ``<-`` ``function``(``data``, ``i``)`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``data``[``i``]``)`\
`res`` ``<-`` `[`boot`](https://rdrr.io/pkg/boot/man/boot.html)`(``data ``=`` ``x``, statistic ``=`` ``my_stat``, R ``=`` ``1000``)`

By default, [`boot()`](https://rdrr.io/pkg/boot/man/boot.html) provides
no feedback on how far it has progressed. However, we can easily add
progress reporting using the
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function:

\
[`library`](https://rdrr.io/r/base/library.html)`(``boot``)`\
\
[`library`](https://rdrr.io/r/base/library.html)`(`[`progressify`](https://progressify.futureverse.org)`)`\
[`handlers`](https://progressr.futureverse.org/reference/handlers.html)`(``global ``=`` ``TRUE``)`\
\
`x`` ``<-`` ``1``:``100`\
`my_stat`` ``<-`` ``function``(``data``, ``i``)`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``data``[``i``]``)`\
`res`` ``<-`` `[`boot`](https://rdrr.io/pkg/boot/man/boot.html)`(``data ``=`` ``x``, statistic ``=`` ``my_stat``, R ``=`` ``1000``)`` ``|>`` `[`progressify`](https://progressify.futureverse.org/reference/progressify.md)`(``)`

## Supported Functions

The
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function supports the following **boot** functions:

- [`boot()`](https://rdrr.io/pkg/boot/man/boot.html)
- [`censboot()`](https://rdrr.io/pkg/boot/man/censboot.html)
- [`tsboot()`](https://rdrr.io/pkg/boot/man/tsboot.html)
