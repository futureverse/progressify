xs <- list(1, 1:2, 1:2, 1:5)

# ------------------------------------------
# Base R apply functions
# ------------------------------------------
y <- lapply(X = xs, FUN = function(x) {
  sum(x)
}) |> progressify()
str(y)
