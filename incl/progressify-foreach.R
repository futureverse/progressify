if (require("foreach")) {
  xs <- list(1, 1:2, 1:2, 1:5)
  y <- foreach(x = xs) %do% {
    sum(x)
  } |> progressify()
  str(y)
} ## if (require("foreach"))
