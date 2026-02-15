# lapply(X = xs, FUN = FUN, ...) =>
#
# local(
#   lapply(X = (.progressr_along <- xs), FUN = function(..., .progressr_progressor) {
#     on.exit(.progressr_progressor())
#     FUN(...)
#   }, .progressr_progressor = progressr::progressor(along = .progressr_along))
# )
#
progressify_base <- local({
  function(expr, fcn_name, fcn, ..., envir = parent.frame()) {
    names <- names(expr)
    if (is.null(names)) names <- rep("", length.out = length(expr))
    names <- names[-1]
    target_names <- names(formals(fcn))[seq_along(names)]
    unnamed <- setdiff(target_names, names)
    names[names == ""] <- unnamed
    names <- c("", names)

    if (fcn_name %in% c("eapply")) {
      idx_X <- which(names == "env")
      idx_FUN <- which(names == "FUN")
    } else if (fcn_name %in% c("lapply", "sapply", "vapply")) {
      idx_X <- which(names == "X")
      idx_FUN <- which(names == "FUN")
    } else if (fcn_name %in% c("replicate")) {
      stop("Not implemented")
    } else {
      idx_X <- NULL
      idx_FUN <- which(names == "FUN")
    }

    parts <- as.list(expr)

    if (!is.null(idx_X)) {
      stopifnot(length(idx_X) == 1L)
      parts[[idx_X]] <- bquote({ .progressr_along <- .(parts[[idx_X]]) })
    }

    if (!is.null(idx_FUN)) {
      stopifnot(length(idx_FUN) == 1L)
      FUN <- expr[[idx_FUN]]
      t_FUN <- bquote(function(..., .progressr_progressor) {
        on.exit(.progressr_progressor())
        .(FUN)(...)
      })
      parts[[idx_FUN]] <- t_FUN
    }

    progressr_args <- list(
      .progressr_progressor = quote(progressr::progressor(along = .progressr_along))
    )
    parts <- c(parts, progressr_args)
    t_expr <- bquote(local(.(as.call(parts))))
  
    t_expr
  } ## progressify_base()
})


append_builtin_transpilers_for_base <- local({
  append_transpilers <- import_futurize("append_transpilers")
  bquote_compile <- import_futurize("bquote_compile")
  bquote_apply <- import_futurize("bquote_apply")
  
  known_fcns <- list(
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

  template <- bquote_compile(function(expr, options) {
    fcn <- get(.(fcn_name), mode = "function", envir = baseenv())
    progressify_base(expr, fcn_name = .(fcn_name), fcn = fcn, envir = parent.frame())
  })

  make_transpiler <- function(fcn_name) {
    transpiler <- eval(bquote_apply(template))
    eval(transpiler)
  }

  function() {
    ## base::apply(), ...
    transpilers <- list()
    for (fcn_name in names(known_fcns)) {
      transpilers[[fcn_name]] <- list(
        label = sprintf("base::%s() transpiler", fcn_name),
        transpiler = make_transpiler(fcn_name)
      )
    } ## for (fcn_name ...)
    transpilers <- list(base = transpilers)
    
    append_transpilers("progressify::built-in", transpilers)
    
    ## Return required packages
    c("base", "progressr")
  }
})

