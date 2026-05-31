#' @tags pkg-lme4
if (requireNamespace("lme4", quietly = TRUE)) {
  library(progressify)
  library(lme4)

  options(progressify.debug = TRUE)

  # 1. Fit standard linear mixed model
  fm1 <- lmer(Reaction ~ Days + (Days | Subject), sleepstudy)
  my_stat <- function(fit) {
    fixef(fit)
  }

  exprs <- list(
    bootMer = quote(bootMer(fm1, my_stat, nsim = 10L))
  )

  for (name in names(exprs)) {
    message(sprintf("Testing %s ...", name))
    expr <- exprs[[name]]

    # Ensure reproducible seed
    set.seed(42)
    truth <- eval(expr)

    set.seed(42)
    res <- eval(bquote(.(expr) |> progressify()))

    # Ensure results are equivalent
    stopifnot(all.equal(res$t, truth$t))
    stopifnot(all.equal(res$t0, truth$t0))

    # Ensure no stdout leakage
    output <- utils::capture.output({
      set.seed(42)
      res2 <- eval(bquote(.(expr) |> progressify()))
    })
    stopifnot(length(output) == 0L)

    # Ensure repeated evaluation is identical
    stopifnot(all.equal(res2$t, res$t))

    message(sprintf("Testing %s ... done", name))
  }
}
