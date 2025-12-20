xs <- list(1, 1:2, 1:2, 1:5)

# ------------------------------------------
# purrr map-reduce functions
# ------------------------------------------
if (require("purrr")) {
  y <- map(xs, function(x) {
    sum(x)
  }) |>
    progressify()
  str(y)
} ## if (require("purrr"))
