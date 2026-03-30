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

} # if (requireNamespace("partykit"))
