known_fcns <- list()
known_fcns[["base"]] <- list(
  apply = c,
  by = c,
  eapply = c,              ## done
  lapply = c,              ## done
  .mapply = c,
  mapply = c,
  Map = c,
  replicate = c,
  sapply = c,              ## done
  tapply = c,
  vapply = c              ## done
)


# lapply(X = xs, FUN = FUN, ...) =>
#
# local(
#   lapply(X = (.progressr_along <- xs), FUN = function(..., .progressr_progressor) {
#     on.exit(.progressr_progressor())
#     FUN(...)
#   }, .progressr_progressor = progressr::progressor(along = .progressr_along))
# )
#
progressify_base <- function(expr, fcn_name, ..., envir = parent.frame()) {
  fcns <- known_fcns[["base"]]

  names <- names(expr)
  if (fcn_name %in% c("eapply")) {
    idx_X <- which(names == "env")
    stopifnot(length(idx_X) == 1L)
    X <- expr[[idx_X]]
    idx_FUN <- which(names == "FUN")
    stopifnot(length(idx_FUN) == 1L)
    FUN <- expr[[idx_FUN]]
  } else if (fcn_name %in% c("lapply", "sapply", "vapply")) {
    idx_X <- which(names == "X")
    stopifnot(length(idx_X) == 1L)
    X <- expr[[idx_X]]
    idx_FUN <- which(names == "FUN")
    stopifnot(length(idx_FUN) == 1L)
    FUN <- expr[[idx_FUN]]
  } else if (fcn_name %in% c("replicate")) {
    stop("Not implemented")
  } else {
    idx_FUN <- which(names == "FUN")
    stopifnot(length(idx_FUN) == 1L)
    FUN <- expr[[idx_FUN]]
  }

  t_FUN <- bquote(function(..., .progressr_progressor) {
    on.exit(.progressr_progressor())
    .(FUN)(...)
  })
  parts <- as.list(expr)
  parts[[idx_X]] <- bquote({ .progressr_along <- .(parts[[idx_X]]) })
  parts[[idx_FUN]] <- t_FUN
  progressr_args <- list(
    .progressr_progressor = quote(progressr::progressor(along = .progressr_along))
  )
  parts <- c(parts, progressr_args)
  t_expr <- bquote(local(.(as.call(parts))))

  list(expr = expr, t_expr = t_expr)
} ## progressify_base()
