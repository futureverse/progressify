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

## Expression unwrapping

The transpilation mechanism includes logic to "unwrap" expressions
enclosed in constructs such as `!`,
[`{ }`](https://rdrr.io/r/base/Paren.html), `( )`,
[`local()`](https://rdrr.io/r/base/eval.html),
[`I()`](https://rdrr.io/r/base/AsIs.html),
[`identity()`](https://rdrr.io/r/base/identity.html),
[`invisible()`](https://rdrr.io/r/base/invisible.html),
[`suppressMessages()`](https://rdrr.io/r/base/message.html),
[`suppressWarnings()`](https://rdrr.io/r/base/warning.html),
[`suppressPackageStartupMessages()`](https://rdrr.io/r/base/message.html),
[`withCallingHandlers()`](https://rdrr.io/r/base/conditions.html), and
[`with()`](https://rdrr.io/r/base/with.html). The transpiler descends
through wrapping constructs until it finds a transpilable expression,
avoiding the need to place `progressify()` inside such constructs. This
allows for patterns like:

    y <- {
      lapply(xs, fcn)
    } |> suppressMessages() |> progressify()

avoiding having to write:

    y <- {
      lapply(xs, fcn) |> progressify()
    } |> suppressMessages()

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
