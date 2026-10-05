# Progress updates for 'SimDesign' functions

The **progressify** package allows you to easily add progress reporting
to sequential and parallel map-reduce code by piping to the
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function. Easy!

## TL;DR

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`progressify`](https://progressify.futureverse.org)`)`\
[`handlers`](https://progressr.futureverse.org/reference/handlers.html)`(``global ``=`` ``TRUE``)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`SimDesign`](http://philchalmers.github.io/SimDesign/)`)`\
\
`# Create small design`\
`Design`` ``<-`` `[`createDesign`](http://philchalmers.github.io/SimDesign/reference/createDesign.md)`(``factor1 ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``1``, ``2``)``)`\
\
`Generate`` ``<-`` ``function``(``condition``, ``fixed_objects`` ``=`` ``NULL``)`` ``{`\
`  `[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``100``)`\
`}`\
\
`Analyse`` ``<-`` ``function``(``condition``, ``dat``, ``fixed_objects`` ``=`` ``NULL``)`` ``{`\
`  `[`mean`](https://rdrr.io/r/base/mean.html)`(``dat``)`\
`}`\
\
`Summarise`` ``<-`` ``function``(``condition``, ``results``, ``fixed_objects`` ``=`` ``NULL``)`` ``{`\
`  `[`mean`](https://rdrr.io/r/base/mean.html)`(``results``)`\
`}`\
\
`# Run simulation with progress signaling`\
`res`` ``<-`` `[`runSimulation`](http://philchalmers.github.io/SimDesign/reference/runSimulation.md)`(``design ``=`` ``Design``, replications ``=`` ``100``,`\
`                     generate ``=`` ``Generate``, analyse ``=`` ``Analyse``,`\
`                     summarise ``=`` ``Summarise``)`` ``|>`` `[`progressify`](https://progressify.futureverse.org/reference/progressify.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to add progress
reporting to
**[SimDesign](https://cran.r-project.org/package=SimDesign)** functions
such as
[`runSimulation()`](http://philchalmers.github.io/SimDesign/reference/runSimulation.md).
The **SimDesign** package provides a comprehensive framework for Monte
Carlo simulation studies in R. For example,
[`runSimulation()`](http://philchalmers.github.io/SimDesign/reference/runSimulation.md)
evaluates the `generate` and `analyse` functions `replications` times
for each condition in the `design`:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`SimDesign`](http://philchalmers.github.io/SimDesign/)`)`\
\
`Design`` ``<-`` `[`createDesign`](http://philchalmers.github.io/SimDesign/reference/createDesign.md)`(``factor1 ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``1``, ``2``)``)`\
`Generate`` ``<-`` ``function``(``condition``, ``fixed_objects`` ``=`` ``NULL``)`` `[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``100``)`\
`Analyse`` ``<-`` ``function``(``condition``, ``dat``, ``fixed_objects`` ``=`` ``NULL``)`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``dat``)`\
`Summarise`` ``<-`` ``function``(``condition``, ``results``, ``fixed_objects`` ``=`` ``NULL``)`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``results``)`\
\
`res`` ``<-`` `[`runSimulation`](http://philchalmers.github.io/SimDesign/reference/runSimulation.md)`(``design ``=`` ``Design``, replications ``=`` ``100``,`\
`                     generate ``=`` ``Generate``, analyse ``=`` ``Analyse``,`\
`                     summarise ``=`` ``Summarise``)`

By default,
[`runSimulation()`](http://philchalmers.github.io/SimDesign/reference/runSimulation.md)
provides its own text/console-based progress bar. However, we can easily
replace this with **progressr**-based reporting using the
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`SimDesign`](http://philchalmers.github.io/SimDesign/)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`progressify`](https://progressify.futureverse.org)`)`\
[`handlers`](https://progressr.futureverse.org/reference/handlers.html)`(``global ``=`` ``TRUE``)`\
\
`res`` ``<-`` `[`runSimulation`](http://philchalmers.github.io/SimDesign/reference/runSimulation.md)`(``design ``=`` ``Design``, replications ``=`` ``100``,`\
`                     generate ``=`` ``Generate``, analyse ``=`` ``Analyse``,`\
`                     summarise ``=`` ``Summarise``)`` ``|>`` `[`progressify`](https://progressify.futureverse.org/reference/progressify.md)`(``)`

When progressified,
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
automatically silences `SimDesign`’s native console progress bar and
routes the progress updates through `progressr`. This means you can use
any of the [supported progressr
handlers](https://progressr.futureverse.org/articles/progressr-11-handlers.html),
e.g., Shiny progress bars, system notifications, or CLI progress
spinners.

## Supported Functions

The
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function supports the following **SimDesign** functions:

- [`runSimulation()`](http://philchalmers.github.io/SimDesign/reference/runSimulation.md)
