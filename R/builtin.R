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
progressify_base <- function(expr, fcn_name, fcn, ..., envir = parent.frame()) {
  fcns <- known_fcns[["base"]]

  names <- names(expr)
  if (is.null(names)) names <- rep("", length.out = length(expr))
  names <- names[-1]
  target_names <- names(formals(fcn))[seq_along(names)]
  unnamed <- setdiff(target_names, names)
  names[names == ""] <- unnamed
  names <- c("", names)

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

  t_expr
} ## progressify_base()


append_builtin_transpilers_for_base <- local({
  append_transpilers <- import_from("append_transpilers", package = "futurize")
  function() {
    ## base::apply(), ...
    transpilers <- list()
  
    ## Create all transpilers
    fcns <- known_fcns[["base"]]
    for (fcn_name in names(fcns)) {
      label <- sprintf("base::%s() transpiler", fcn_name)
      make_transpiler_expr <- bquote(function(expr, options) {
        fcn_name <- .(fcn_name)
        fcn <- get(fcn_name, mode = "function", envir = baseenv())
        progressify_base(expr, fcn_name = fcn_name, fcn = fcn, envir = parent.frame())
      })
      transpiler <- eval(make_transpiler_expr)
      transpilers[[fcn_name]] <- list(
        label = label,
        transpiler = transpiler
      )
    } ## for (fcn_name ...)
    
    append_transpilers("progressify::built-in", list(base = transpilers))
    
    ## Return required packages
    character(0L)
  }
})

