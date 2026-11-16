#' @tags pkg-partykit
if (requireNamespace("partykit")) {

library(progressify)
library(partykit)

options(progressify.debug = TRUE)

data("Titanic", package = "datasets")
tt <- as.data.frame(Titanic)

## -------------------------------------------------------
## cforest
## -------------------------------------------------------
exprs <- list(
  cforest = quote(cforest(Survived ~ ., data = tt, ntree = 20L)),
  cforest = quote(partykit::cforest(Survived ~ ., data = tt, ntree = 20L))
)

for (kk in seq_along(exprs)) {
  name <- names(exprs)[kk]
  expr <- exprs[[kk]]
  message()
  message(sprintf("=== %s ==========================", name))
  print(expr)
  message(sprintf("---------------------------------"))
  
  ## Fix random seed for reproducibility
  set.seed(1L)
  truth <- eval(expr)

  expr_f <- bquote(.(expr) |> progressify())
  print(expr_f)

  set.seed(1L)
  res <- eval(expr_f)

  ## We can't use identical() because cforest objects might contain 
  ## different call objects (e.g. including the injected applyfun)
  ## but we can check if the predicted values are identical.
  pred_truth <- predict(truth)
  pred_res <- predict(res)

  if (!identical(pred_res, pred_truth)) {
    str(list(truth = pred_truth, res = pred_res))
    stop("Predictions are not identical")
  } else {
    message("Predictions match!")
  }

  out <- utils::capture.output({
    expr_f2 <- bquote(.(expr) |> progressify())
    set.seed(1L)
    res2 <- eval(expr_f2)
  })
  print(out)
  stopifnot(identical(out, character(0L)))
  
  pred_res2 <- predict(res2)
  stopifnot(identical(pred_res2, pred_res))

  expr_f3 <- bquote(.(expr) |> progressify())
  set.seed(1L)
  res3 <- eval(expr_f3)
  pred_res3 <- predict(res3)
  stopifnot(identical(pred_res3, pred_res))
}


## -------------------------------------------------------
## varimp() for 'cforest' objects
## -------------------------------------------------------
ntree <- 10L
set.seed(42L)
forest <- cforest(Survived ~ ., data = tt, ntree = ntree)

exprs <- list(
  varimp = quote(varimp(forest)),
  varimp = quote(partykit::varimp(forest)),
  varimp = quote(varimp(forest, nperm = 2L)),
  varimp.cforest = quote(varimp.cforest(forest)),
  varimp.cforest = quote(partykit::varimp.cforest(forest)),
  ## Dispatch argument is not a variable => method identified at run time
  varimp = quote(varimp(cforest(Survived ~ ., data = tt, ntree = ntree)))
)

for (kk in seq_along(exprs)) {
  name <- names(exprs)[kk]
  expr <- exprs[[kk]]
  message()
  message(sprintf("=== %s ==========================", name))
  print(expr)
  message(sprintf("---------------------------------"))

  set.seed(1L)
  truth <- eval(expr)

  expr_f <- bquote(.(expr) |> progressify())
  print(expr_f)

  ## Count progress updates; progressr.enable = TRUE makes progressor()
  ## signal 'progression' conditions also in non-interactive mode
  nupdates <- 0L
  oopts <- options(progressr.enable = TRUE)
  set.seed(1L)
  res <- withCallingHandlers(eval(expr_f), progression = function(p) {
    if (identical(p[["type"]], "update")) nupdates <<- nupdates + 1L
    invokeRestart("muffleProgression")
  })
  options(oopts)
  str(list(truth = truth, res = res, nupdates = nupdates))
  stopifnot(identical(res, truth))
  stopifnot(nupdates == ntree)

  ## No output
  out <- utils::capture.output({
    set.seed(1L)
    res2 <- eval(expr_f)
  })
  stopifnot(identical(out, character(0L)))
  stopifnot(identical(res2, truth))
}


## varimp() for non-supported 'constparty' objects
tree <- ctree(Survived ~ ., data = tt)
res <- tryCatch(varimp(tree) |> progressify(), error = identity)
print(res)
stopifnot(inherits(res, "error"))

} # if (requireNamespace("partykit"))
