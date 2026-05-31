#' @tags pkg-boot
if (requireNamespace("boot", quietly = TRUE)) {
  library(progressify)
  library(boot)
  if (requireNamespace("survival", quietly = TRUE)) {
    library(survival)
  }

  options(progressify.debug = TRUE)

  # 1. boot::boot test setup
  x <- 1:100
  my_stat <- function(data, i) mean(data[i])

  # 2. boot::censboot test setup
  data(aml, package = "boot")
  aml.fun <- function(data) {
    surv <- survfit(Surv(time, cens) ~ group, data = data)
    out <- NULL
    st <- 1
    for (s in seq_along(surv$strata)) {
      inds <- st:(st + surv$strata[s] - 1)
      md <- min(surv$time[inds[1 - surv$surv[inds] >= 0.5]])
      st <- st + surv$strata[s]
      out <- c(out, md)
    }
    out
  }

  # 3. boot::tsboot test setup
  lynx.fun <- function(tsb) {
    c(mean(tsb), tsb)
  }

  exprs <- list(
    boot = quote(boot(data = x, statistic = my_stat, R = 10L)),
    censboot = quote(censboot(aml, aml.fun, R = 10L, strata = aml$group)),
    tsboot = quote(tsboot(log(lynx), lynx.fun, R = 10L, l = 20, sim = "geom"))
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
    # We compare the $t slot (simulations results matrix) as calls might contain wrapped closure info
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
