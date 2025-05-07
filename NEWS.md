# Version 0.0.1 (2025-05-06)

 * The `progressify()` function makes common map-reduce functions
   to report on progress.ons are relayed, among other things.

 * Add support for base R, e.g. `y <- lapply(xs, fcn) |> progressify()`.

 * Add support for **purrr**, e.g. `y <- map(xs, fcn) |> progressify()`.
 
 * Add support for **foreach**, e.g. `y <- foreach(x = xs) %do% {
   fcn(x) } |> progressify()`.
 
 * Add support for **plyr**, e.g. `y <- llply(xs, fcn) |>
   progressify()`.
 
