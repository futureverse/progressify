## Pre-compiled bquote templates shared across transpilers

## Length-based step count from 'data' argument
template_along <- bquote_compile({
  .progressr_progressor <- progressr::progressor(along = .(ALONG))
  .(ALONG)
})

## Length-based step count from first element of list
template_along_first <- bquote_compile({
  .progressr_progressor <- progressr::progressor(along = .(ALONG)[[1]])
  .(ALONG)
})

## Step count from numeric argument
template_steps <- bquote_compile({
  .progressr_progressor <- progressr::progressor(steps = .(STEPS))
  .(STEPS)
})

## Step count from nrow() of 'data' argument
template_steps_nrow <- bquote_compile({
  .progressr_progressor <- progressr::progressor(steps = nrow(.(DATA)))
  .(DATA)
})

## Pass progressor via '...' arguments
template_FUN <- bquote_compile(function(..., ...FUN, .progressr_progressor) {
  on.exit(.progressr_progressor())
  ...FUN(...)
})

## purrr-style .f wrapper: uses as_mapper() for formula/string/integer support
template_f <- bquote_compile(local({
  .progressr_f <- purrr::as_mapper(.(FUN))
  function(..., .progressr_progressor) {
    on.exit(.progressr_progressor())
    .progressr_f(...)
  }
}))

## Wrap 'expr' with on.exit() progress signaling
template_expr <- bquote_compile(local({
  on.exit(.progressr_progressor())
  .(EXPR)
}))

## Wrap call with progressor in enclosing environment
template_outer <- bquote_compile(local({
  .progressr_progressor <- progressr::progressor(along = .(ALONG))
  .(EXPR)
}))
