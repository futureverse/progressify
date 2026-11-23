#' @tags pkg-car
if (requireNamespace("car", quietly = TRUE)) {

library(progressify)
library(car)

options(progressify.debug = TRUE)

fit_lm <- lm(mpg ~ wt + hp, data = mtcars)
fit_glm <- glm(am ~ wt, data = mtcars, family = binomial())
DNase1 <- subset(DNase, Run == 1)
fit_nls <- nls(density ~ SSlogis(log(conc), Asym, xmid, scal), data = DNase1)
my_f <- function(fit) coef(fit)[1:2]

R <- 5L
exprs <- list(
  Boot = quote(Boot(fit_lm, R = R)),
  Boot = quote(car::Boot(fit_lm, R = R)),
  Boot = quote(Boot(fit_lm, my_f, R = R)),
  Boot = quote(Boot(fit_lm, f = my_f, labels = c("a", "b"), R = R)),
  Boot = quote(Boot(fit_lm, coef, c("a", "b", "c"), R)),
  Boot = quote(Boot(fit_lm, R = R, method = "residual")),
  Boot = quote(Boot(fit_glm, R = R)),
  Boot = quote(Boot(fit_nls, R = R)),
  Boot = quote(Boot(lm(mpg ~ wt, data = mtcars), f = function(fit) coef(fit), R = R))
)

## Compare the bootstrap replicates, because the 'statistic' element of
## the result is a local function, which differs between calls
as_comparable <- function(x) {
  x[c("t0", "t", "R")]
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
    identical(as_comparable(res), as_comparable(truth)),
    identical(colnames(res$t), colnames(truth$t)),
    nupdates == R
  )

  ## No output
  out <- utils::capture.output({
    set.seed(42L)
    res2 <- eval(expr_f)
  })
  stopifnot(
    length(out) == 0L,
    identical(as_comparable(res2), as_comparable(truth))
  )
}


## Default 'R'
nupdates <- 0L
oopts_progressr <- options(progressr.enable = TRUE)
res <- withCallingHandlers(Boot(fit_lm) |> progressify(), progression = function(p) {
  if (identical(p[["type"]], "update")) nupdates <<- nupdates + 1L
  invokeRestart("muffleProgression")
})
options(oopts_progressr)
stopifnot(nupdates == eval(formals(car::Boot)[["R"]]))

} # if (requireNamespace("car", quietly = TRUE))
