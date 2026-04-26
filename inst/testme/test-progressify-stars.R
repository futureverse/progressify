#' @tags pkg-stars
if (requireNamespace("stars")) {

library(progressify)
library(stars)

options(progressify.debug = FALSE)

tif <- system.file("tif/L7_ETMs.tif", package = "stars")
x <- read_stars(tif)
print(x)

message("--- st_apply(x, 1:2, mean) ---")
res1_truth <- st_apply(x, 1:2, mean)
print(res1_truth)
res1 <- st_apply(x, 1:2, mean) |> progressify()
print(res1)
stopifnot(identical(res1, res1_truth))


message("--- st_apply(x, 1:2, ..., single_arg = FALSE) ---")
res2_truth <- st_apply(x, 1:2, function(b1, b2, b3, b4, b5, b6) {
  (b1+b2+b3+b4+b5+b6) / 6
}, single_arg = FALSE)
print(res2_truth)
res2 <- st_apply(x, 1:2, function(b1, b2, b3, b4, b5, b6) {
  (b1+b2+b3+b4+b5+b6) / 6
}, single_arg = FALSE) |> progressify()
print(res2)
stopifnot(identical(res2, res2_truth))


message("--- st_apply(x2, 1:2, mean) ---")
x2 <- c(x, x)
res3_truth <- st_apply(x2, 1:2, mean)
print(res3_truth)
res3 <- st_apply(x2, 1:2, mean) |> progressify()
print(res3)
stopifnot(identical(res3, res3_truth))

} ## if (requireNamespace("stars"))
