# Progress updates for 'lme4' functions

The **progressify** package allows you to easily add progress reporting
to sequential and parallel map-reduce code by piping to the
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function. Easy!

## TL;DR

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`progressify`](https://progressify.futureverse.org)`)`\
[`handlers`](https://progressr.futureverse.org/reference/handlers.html)`(``global ``=`` ``TRUE``)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`lme4`](https://github.com/lme4/lme4/)`)`\
\
`# Fit random-slope model`\
`fm1`` ``<-`` `[`lmer`](https://rdrr.io/pkg/lme4/man/lmer.html)`(``Reaction`` ``~`` ``Days`` ``+`` ``(``Days`` ``|`` ``Subject``)``, ``sleepstudy``)`\
`my_stat`` ``<-`` ``function``(``fit``)`` ``{`\
`  `[`fixef`](https://rdrr.io/pkg/nlme/man/fixed.effects.html)`(``fit``)`\
`}`\
\
`# Run bootstrap with progress signaling`\
`res`` ``<-`` `[`bootMer`](https://rdrr.io/pkg/lme4/man/bootMer.html)`(``fm1``, ``my_stat``, nsim ``=`` ``1000``)`` ``|>`` `[`progressify`](https://progressify.futureverse.org/reference/progressify.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to add progress
reporting to **[lme4](https://cran.r-project.org/package=lme4)**
functions such as
[`bootMer()`](https://rdrr.io/pkg/lme4/man/bootMer.html). The **lme4**
package provides functions for fitting linear, generalized linear, and
nonlinear mixed-effects models. For example,
[`bootMer()`](https://rdrr.io/pkg/lme4/man/bootMer.html) runs a
statistic function `nsim` times:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`lme4`](https://github.com/lme4/lme4/)`)`\
\
`# Fit random-slope model`\
`fm1`` ``<-`` `[`lmer`](https://rdrr.io/pkg/lme4/man/lmer.html)`(``Reaction`` ``~`` ``Days`` ``+`` ``(``Days`` ``|`` ``Subject``)``, ``sleepstudy``)`\
`my_stat`` ``<-`` ``function``(``fit``)`` ``{`\
`  `[`fixef`](https://rdrr.io/pkg/nlme/man/fixed.effects.html)`(``fit``)`\
`}`\
\
`res`` ``<-`` `[`bootMer`](https://rdrr.io/pkg/lme4/man/bootMer.html)`(``fm1``, ``my_stat``, nsim ``=`` ``1000``)`

By default, [`bootMer()`](https://rdrr.io/pkg/lme4/man/bootMer.html)
provides no progress feedback. However, we can easily add progress
reporting using the
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`lme4`](https://github.com/lme4/lme4/)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`progressify`](https://progressify.futureverse.org)`)`\
[`handlers`](https://progressr.futureverse.org/reference/handlers.html)`(``global ``=`` ``TRUE``)`\
\
`# Fit random-slope model`\
`fm1`` ``<-`` `[`lmer`](https://rdrr.io/pkg/lme4/man/lmer.html)`(``Reaction`` ``~`` ``Days`` ``+`` ``(``Days`` ``|`` ``Subject``)``, ``sleepstudy``)`\
`my_stat`` ``<-`` ``function``(``fit``)`` ``{`\
`  `[`fixef`](https://rdrr.io/pkg/nlme/man/fixed.effects.html)`(``fit``)`\
`}`\
\
`res`` ``<-`` `[`bootMer`](https://rdrr.io/pkg/lme4/man/bootMer.html)`(``fm1``, ``my_stat``, nsim ``=`` ``1000``)`` ``|>`` `[`progressify`](https://progressify.futureverse.org/reference/progressify.md)`(``)`

## Supported Functions

The
[`progressify()`](https://progressify.futureverse.org/reference/progressify.md)
function supports the following **lme4** functions:

- [`bootMer()`](https://rdrr.io/pkg/lme4/man/bootMer.html)
