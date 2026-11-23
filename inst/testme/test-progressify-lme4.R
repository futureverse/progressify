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


  ## -------------------------------------------------------
  ## confint(<merMod>, method = "boot")
  ## -------------------------------------------------------
  fm2 <- lmer(Reaction ~ Days + (1 | Subject), sleepstudy)
  nsim <- 10L

  exprs <- list(
    confint = quote(confint(fm2, method = "boot", nsim = nsim)),
    confint = quote(stats::confint(fm2, method = "boot", nsim = nsim)),
    confint = quote(confint(fm2, parm = "Days", level = 0.90, method = "boot", nsim = nsim)),
    confint = quote(confint(fm2, method = "boot", nsim = nsim, FUN = fixef)),
    confint = quote(confint(fm2, method = "boot", nsim = nsim, quiet = TRUE)),
    confint = quote(confint(fm2, method = "boot", nsim = nsim, .progress = "txt")),
    ## Dispatch argument is not a variable => method identified at run time
    confint = quote(confint(lmer(Reaction ~ Days + (1 | Subject), sleepstudy), method = "boot", nsim = nsim))
  )

  for (kk in seq_along(exprs)) {
    name <- names(exprs)[kk]
    expr <- exprs[[kk]]
    message(sprintf("Testing %s ...", name))
    print(expr)

    set.seed(42)
    truth <- suppressMessages(eval(expr))
    if (identical(expr[[".progress"]], "txt")) {
      ## Not comparing to built-in text progress bar output
      expr[[".progress"]] <- NULL
    }

    expr_f <- bquote(.(expr) |> progressify())
    print(expr_f)

    ## Count progress updates; progressr.enable = TRUE makes progressor()
    ## signal 'progression' conditions also in non-interactive mode
    search_before <- search()
    nupdates <- 0L
    oopts_progressr <- options(progressr.enable = TRUE)
    set.seed(42)
    res <- withCallingHandlers(eval(expr_f), progression = function(p) {
      if (identical(p[["type"]], "update")) nupdates <<- nupdates + 1L
      invokeRestart("muffleProgression")
    })
    options(oopts_progressr)
    print(list(truth = truth, res = res, nupdates = nupdates))
    stopifnot(
      all.equal(res, truth),
      nupdates == nsim,
      identical(search(), search_before)
    )

    ## No stdout output
    out <- utils::capture.output({
      set.seed(42)
      res2 <- suppressMessages(eval(expr_f))
    })
    stopifnot(length(out) == 0L, all.equal(res2, truth))

    message(sprintf("Testing %s ... done", name))
  }


  ## Methods other than "boot" are not supported
  for (method in c("profile", "Wald")) {
    expr <- bquote(confint(fm2, method = .(method)))
    res <- tryCatch(eval(bquote(.(expr) |> progressify())), error = identity)
    stopifnot(inherits(res, "error"))
    message("Expected error: ", conditionMessage(res))
  }
  res <- tryCatch(confint(fm2) |> progressify(), error = identity)
  stopifnot(inherits(res, "error"))
  message("Expected error: ", conditionMessage(res))
}
