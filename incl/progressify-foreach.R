xs <- list(1, 1:2, 1:2, 1:5)

# ------------------------------------------
# foreach map-reduce functions
# ------------------------------------------
if (require("foreach")) {
  y <- foreach(x = xs) %do%
    {
      sum(x)
    } |>
    progressify()
  str(y)
} ## if (require("foreach"))
