## Pre-compiled bquote templates shared across transpilers

## Length-based step count from 'data' argument
## Evaluate 'data' only once. We must remove local '.progressr_along' before
## returning it, otherwise FUN would carry it along, which we don't want for
## parallel processing
template_along <- bquote_compile({
  .progressr_along <- .(ALONG)
  .progressr_progressor <- progressr::progressor(along = .progressr_along)
  tryCatch(.progressr_along, finally = rm(.progressr_along))
})

## Length-based step count from first element of list
## Zero elements, e.g. purrr::pmap(list(), ...), means zero steps
## We must remove local '.progressr_along' before returning it, otherwise
## FUN would carry it along, which we don't want for parallel processing
template_along_first <- bquote_compile({
  .progressr_along <- .(ALONG)
  .progressr_progressor <- progressr::progressor(
    along = if (length(.progressr_along) > 0L) .progressr_along[[1]] else NULL
  )
  tryCatch(.progressr_along, finally = rm(.progressr_along))
})

## Step count from numeric argument
## Evaluate 'steps' only once
template_steps <- bquote_compile({
  .progressr_steps <- .(STEPS)
  .progressr_progressor <- progressr::progressor(steps = .progressr_steps)
  .progressr_steps
})

## Step count from nrow() of 'data' argument
## Evaluate 'data' only once. We must remove local '.progressr_data' before
## returning it, otherwise FUN would carry it along, which we don't want for
## parallel processing
template_steps_nrow <- bquote_compile({
  .progressr_data <- .(DATA)
  .progressr_progressor <- progressr::progressor(steps = nrow(.progressr_data))
  tryCatch(.progressr_data, finally = rm(.progressr_data))
})

## Pass progressor via '...' arguments
template_FUN <- bquote_compile(function(..., ...FUN, .progressr_progressor) {
  on.exit(.progressr_progressor())
  ...FUN(...)
})

## Wrap FUN as a closure that captures '...FUN' and '.progressr_progressor'
## from the enclosing local() environment.  Used for functions such as
## mapply(), Map(), and .mapply(), whose '...' are the elements to iterate
## over and therefore cannot be used to pass the progressor through to FUN.
template_FUN_closure <- bquote_compile(function(...) {
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
## Evaluate 'along' only once; 'EXPR' must refer to it as '.progressr_along'
template_outer <- bquote_compile(local({
  .progressr_along <- .(ALONG)
  .progressr_progressor <- progressr::progressor(along = .progressr_along)
  .(EXPR)
}))
