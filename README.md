# progressify: Progress Updates Everywhere

The **progressify** package makes it extremely simple to report
progress updates for apply-like, map-reduce calls. All you need to
know is that there is a single function called `progressify()` that
will take care of everything.

It supports base R apply functions, **purrr**, **foreach**, and
**plyr**. Here are some examples how you could use it:

```r
library(progressify)

xs <- 1:10
y <- lapply(xs, sqrt) |> progressify()

xs <- 1:10
y <- purrr::map(xs, sqrt) |> progressify()

xs <- 1:10
y <- foreach(x = xs) %do% { sqrt(x) } |> progressify()

xs <- 1:10
y <- plyr::llply(xs, sqrt) |> progressify()
```
