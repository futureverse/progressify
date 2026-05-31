if (requireNamespace("sandwich", quietly = TRUE)) {
  library(progressify)
  library(sandwich)
  library(stats)

  options(progressify.debug = TRUE)

  fit <- lm(dist ~ speed, data = cars)

  exprs <- list(
    vcovBS = quote(vcovBS(fit, R = 10L)),
    vcovJK = quote(vcovJK(fit))
  )
  for (name in names(exprs)) {
    message(sprintf("Testing %s ...", name))
    expr <- exprs[[name]]
    
    ## (a) Verify identical to truth
    set.seed(42)
    truth <- eval(expr)
    
    set.seed(42)
    res <- eval(bquote(.(expr) |> progressify()))
    stopifnot(all.equal(res, truth))

    ## (b) No stdout leakage
    output <- utils::capture.output({
      set.seed(42)
      res <- eval(bquote(.(expr) |> progressify()))
    })
    stopifnot(length(output) == 0L)

    ## (c) Repeated evaluation produces identical results
    set.seed(42)
    res3 <- eval(bquote(.(expr) |> progressify()))
    stopifnot(all.equal(res3, res))
    
    message(sprintf("Testing %s ... done", name))
  }
}
