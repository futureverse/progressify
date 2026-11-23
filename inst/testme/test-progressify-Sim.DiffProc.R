#' @tags pkg-Sim.DiffProc
if (requireNamespace("Sim.DiffProc", quietly = TRUE)) {

library(progressify)
library(Sim.DiffProc)

options(progressify.debug = TRUE)

## 1-dim model
f <- expression(3 * (1 - x))
g <- expression(0.5)
mod1d <- snssde1d(drift = f, diffusion = g, x0 = 5, T = 10, M = 20, N = 100)
sde.fun1d <- function(data, i) {
  d <- data[i, ]
  c(mean(d), var(d))
}

## 2-dim model, which depends on global variables
mu <- 0.75; sigma <- 0.1; theta <- 2
f2 <- expression(1/mu * (theta - x), x)
g2 <- expression(sqrt(sigma), 0)
mod2d <- snssde2d(drift = f2, diffusion = g2, M = 20, N = 100, x0 = c(x = 0, y = 0))
sde.fun2d <- function(data, i) {
  d <- data[i, ]
  c(mean(d$x), mean(d$y))
}

R <- 5L
exprs <- list(
  MCM.sde = quote(MCM.sde(mod1d, statistic = sde.fun1d, R = R)),
  MCM.sde = quote(Sim.DiffProc::MCM.sde(model = mod1d, statistic = sde.fun1d, R = R, exact = list(m = 1, S = 0.5^2/6))),
  MCM.sde = quote(MCM.sde(mod1d, sde.fun1d, R, time = 5)),
  MCM.sde = quote(MCM.sde(model = mod2d, statistic = sde.fun2d, R = R)),
  ## Dispatch argument is not a variable => method identified at run time
  MCM.sde = quote(MCM.sde(snssde1d(drift = f, diffusion = g, x0 = 5, T = 10, M = 20, N = 100), statistic = sde.fun1d, R = R))
)

## The 'call' element of the result reflects the transpiled call
as_comparable <- function(x) {
  x[["call"]] <- NULL
  x
}

for (kk in seq_along(exprs)) {
  name <- names(exprs)[kk]
  expr <- exprs[[kk]]
  message(sprintf("=== %s ==========================", name))
  print(expr)

  set.seed(42L)
  truth <- eval(expr)

  expr_f <- bquote(.(expr) |> progressify())
  print(expr_f)

  ## Count progress updates; progressr.enable = TRUE makes progressor()
  ## signal 'progression' conditions also in non-interactive mode
  nupdates <- 0L
  oopts_progressr <- options(progressr.enable = TRUE)
  set.seed(42L)
  res <- withCallingHandlers(eval(expr_f), progression = function(p) {
    if (identical(p[["type"]], "update")) nupdates <<- nupdates + 1L
    invokeRestart("muffleProgression")
  })
  options(oopts_progressr)
  str(list(nupdates = nupdates))
  stopifnot(
    all.equal(as_comparable(res), as_comparable(truth)),
    identical(res[["mod"]], truth[["mod"]]),
    nupdates == R
  )

  ## No output
  out <- utils::capture.output({
    set.seed(42L)
    res2 <- eval(expr_f)
  })
  stopifnot(
    length(out) == 0L,
    all.equal(as_comparable(res2), as_comparable(truth))
  )
}


## Default 'R'
nupdates <- 0L
oopts_progressr <- options(progressr.enable = TRUE)
res <- withCallingHandlers(MCM.sde(mod1d, statistic = sde.fun1d) |> progressify(), progression = function(p) {
  if (identical(p[["type"]], "update")) nupdates <<- nupdates + 1L
  invokeRestart("muffleProgression")
})
options(oopts_progressr)
stopifnot(nupdates == eval(formals(getS3method("MCM.sde", "default"))[["R"]]))

} # if (requireNamespace("Sim.DiffProc", quietly = TRUE))
