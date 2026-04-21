# Evaluate a regular map-reduce call with progress updates

Evaluate a regular map-reduce call with progress updates

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

  If TRUE (default), the progressified expression is evaluated,
  otherwise it is returned.

- envir:

  The environment in which `expr` is evaluated.

- ...:

  Not used.

## Value

Returns the value of the evaluated expression `expr`.

## Examples

``` r
handlers(global = TRUE) # listen to progress updates
#> Error in globalCallingHandlers(condition = global_progression_handler): should not be called with handlers on the stack

xs <- list(1, 1:2, 1:2, 1:5)
y <- lapply(X = xs, FUN = sum) |> progressify()
str(y)
#> List of 4
#>  $ : num 1
#>  $ : int 3
#>  $ : int 3
#>  $ : int 15
```
