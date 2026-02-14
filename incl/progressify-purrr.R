if (require("purrr")) {
  xs <- list(1, 1:2, 1:2, 1:5)
  y <- map(xs, sum) |> progressify()
  str(y)
} ## if (require("purrr"))
