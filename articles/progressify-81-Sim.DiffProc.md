# Progress updates for 'Sim.DiffProc' functions

The **progressify** package allows you to easily add progress reporting
to sequential and parallel map-reduce code by piping to the
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function. Easy!

## TL;DR

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`progressify`](https://progressify.futureverse.org)`)`\
[`handlers`](https://progressr.futureverse.org/reference/handlers.html)`(``global ``=`` ``TRUE``)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`Sim.DiffProc`](https://github.com/acguidoum/Sim.DiffProc)`)`\
\
`f`` ``<-`` `[`expression`](https://rdrr.io/r/base/expression.html)`(``3`` ``*`` ``(``1`` ``-`` ``x``)``)`\
`g`` ``<-`` `[`expression`](https://rdrr.io/r/base/expression.html)`(``0.5``)`\
`mod`` ``<-`` `[`snssde1d`](https://rdrr.io/pkg/Sim.DiffProc/man/snssde1d.html)`(``drift ``=`` ``f``, diffusion ``=`` ``g``, x0 ``=`` ``5``, T ``=`` ``10``, M ``=`` ``50``)`\
`stat`` ``<-`` ``function``(``data``, ``i``)`` ``{`\
`  ``d`` ``<-`` ``data``[``i``, ``]`\
`  `[`c`](https://rdrr.io/r/base/c.html)`(`[`mean`](https://rdrr.io/r/base/mean.html)`(``d``)``, `[`var`](https://rdrr.io/r/stats/cor.html)`(``d``)``)`\
`}`\
\
`res`` ``<-`` `[`MCM.sde`](https://rdrr.io/pkg/Sim.DiffProc/man/MCM.sde.html)`(``mod``, statistic ``=`` ``stat``, R ``=`` ``100``)`` ``|>`` `[`progressify`](https://progressify.futureverse.org/reference/progressify.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to add progress
reporting to
**[Sim.DiffProc](https://cran.r-project.org/package=Sim.DiffProc)**
functions such as
[`MCM.sde()`](https://rdrr.io/pkg/Sim.DiffProc/man/MCM.sde.html).

The **Sim.DiffProc**
[`MCM.sde()`](https://rdrr.io/pkg/Sim.DiffProc/man/MCM.sde.html)
function performs parallel Monte Carlo estimation of statistics of
stochastic differential equations (SDEs). It simulates the SDE model `R`
times, and then calculates the statistics of interest from these
simulations. For example,

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`Sim.DiffProc`](https://github.com/acguidoum/Sim.DiffProc)`)`\
\
`## dX(t) = 3*(1-X(t)) dt + 0.5 * dW(t), X(0)=5, t in [0,10]`\
`f`` ``<-`` `[`expression`](https://rdrr.io/r/base/expression.html)`(``3`` ``*`` ``(``1`` ``-`` ``x``)``)`\
`g`` ``<-`` `[`expression`](https://rdrr.io/r/base/expression.html)`(``0.5``)`\
`mod`` ``<-`` `[`snssde1d`](https://rdrr.io/pkg/Sim.DiffProc/man/snssde1d.html)`(``drift ``=`` ``f``, diffusion ``=`` ``g``, x0 ``=`` ``5``, T ``=`` ``10``, M ``=`` ``50``)`\
\
`stat`` ``<-`` ``function``(``data``, ``i``)`` ``{`\
`  ``d`` ``<-`` ``data``[``i``, ``]`\
`  `[`c`](https://rdrr.io/r/base/c.html)`(`[`mean`](https://rdrr.io/r/base/mean.html)`(``d``)``, `[`var`](https://rdrr.io/r/stats/cor.html)`(``d``)``)`\
`}`\
\
`res`` ``<-`` `[`MCM.sde`](https://rdrr.io/pkg/Sim.DiffProc/man/MCM.sde.html)`(``mod``, statistic ``=`` ``stat``, R ``=`` ``100``)`

Here [`MCM.sde()`](https://rdrr.io/pkg/Sim.DiffProc/man/MCM.sde.html)
provides no feedback on how far it has progressed, but we can easily add
progress reporting by using:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`Sim.DiffProc`](https://github.com/acguidoum/Sim.DiffProc)`)`\
\
[`library`](https://rdrr.io/r/base/library.html)`(`[`progressify`](https://progressify.futureverse.org)`)`\
[`handlers`](https://progressr.futureverse.org/reference/handlers.html)`(``global ``=`` ``TRUE``)`\
\
`res`` ``<-`` `[`MCM.sde`](https://rdrr.io/pkg/Sim.DiffProc/man/MCM.sde.html)`(``mod``, statistic ``=`` ``stat``, R ``=`` ``100``)`` ``|>`` `[`progressify`](https://progressify.futureverse.org/reference/progressify.md)`(``)`

This reports on progress for each of the `R` simulations, which is where
most of the processing time is spent. Using the default progress
handler, the progress reporting will appear as:

```
  |=====                    |  20%
```

## Supported Functions

The
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function supports the following **Sim.DiffProc** functions:

- [`MCM.sde()`](https://rdrr.io/pkg/Sim.DiffProc/man/MCM.sde.html)

## Limitations

To combine
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
with
[`futurize()`](https://futurize.futureverse.org/reference/futurize.html)
of the **[futurize](https://futurize.futureverse.org)** package, which
runs the simulations in parallel, use:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`\
\
`res`` ``<-`` `[`MCM.sde`](https://rdrr.io/pkg/Sim.DiffProc/man/MCM.sde.html)`(``mod``, statistic ``=`` ``stat``, R ``=`` ``100``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.html)`(``)`` ``|>`` `[`progressify`](https://progressify.futureverse.org/reference/progressify.md)`(``)`

The reverse order, `|> progressify() |> futurize()`, gives an error.
There are no progress updates when
[`MCM.sde()`](https://rdrr.io/pkg/Sim.DiffProc/man/MCM.sde.html)
parallelizes via its own `parallel = "multicore"` or `parallel = "snow"`
arguments.
