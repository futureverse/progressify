xs <- list(1, 1:2, 1:2, 1:5)

# ------------------------------------------
# plyr map-reduce functions
# ------------------------------------------
if (require("plyr")) {

y <- llply(xs, sum) |> progressify()
str(y)

} ## if (require("plyr"))
