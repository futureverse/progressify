#' @tags pkg-fwb
if (requireNamespace("fwb", quietly = TRUE)) {
  library(progressify)
  library(fwb)

  options(progressify.debug = TRUE)

  # 1. fwb::fwb test setups
  data <- mtcars
  my_stat <- function(data, w) {
    coef(lm(mpg ~ cyl, data = data, weights = w))
  }

  exprs <- list(
    fwb_simple_true = quote(fwb(data = data, statistic = my_stat, R = 10L, simple = TRUE, verbose = FALSE)),
    fwb_simple_false = quote(fwb(data = data, statistic = my_stat, R = 10L, simple = FALSE, verbose = FALSE)),
    fwb_verbose_default = quote(fwb(data = data, statistic = my_stat, R = 10L))
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
    # We compare the $t slot (simulations results matrix) and $t0 (original estimate)
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
