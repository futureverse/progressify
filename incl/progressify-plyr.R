if (require("plyr")) {
  xs <- list(1, 1:2, 1:2, 1:5)
  y <- llply(xs, sum) |> progressify()
  str(y)
} ## if (require("plyr"))
