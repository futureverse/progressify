# Evaluate a regular map-reduce call in parallel

Evaluate a regular map-reduce call in parallel

## Usage

``` r
progressify(
  expr,
  substitute = TRUE,
  ...,
  when = TRUE,
  eval = TRUE,
  envir = parent.frame()
)
```

## Arguments

- expr:

  An R expression.

- substitute:

  If TRUE, `expr` is quoted.

- when:

  If TRUE (default), the expression is progressified, otherwise not.

- eval:

  If TRUE (default), the progressified expression is evaluated, other it
  is returned.

- envir:

  The environment in which `expr` is evaluated.

- ...:

  Not used.

## Value

Returns the value of the evaluated expression `expr`.

## Examples

``` r
xs <- list(1, 1:2, 1:2, 1:5)
y <- lapply(X = xs, FUN = sum) |> progressify()
str(y)
#> List of 4
#>  $ : num 1
#>  $ : int 3
#>  $ : int 3
#>  $ : int 15
```
