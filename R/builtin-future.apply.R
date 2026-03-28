# future.apply::future_lapply(X = xs, FUN = FUN, ...) =>
#
# local(
#   future.apply::future_lapply(X = (.progressr_along <- xs), FUN = function(..., .progressr_progressor) {
#     on.exit(.progressr_progressor())
#     FUN(...)
#   }, .progressr_progressor = progressr::progressor(along = .progressr_along))
# )
#
progressify_future.apply <- local({
  ## Pre-compiled bquote templates
  template_along <- bquote_compile({
    .progressr_progressor <- progressr::progressor(along = .(ALONG))
    .(ALONG)
  })

  template_steps_nrow <- bquote_compile({
    .progressr_progressor <- progressr::progressor(steps = nrow(.(DATA)))
    .(DATA)
  })

  template_steps <- bquote_compile({
    .progressr_progressor <- progressr::progressor(steps = .(STEPS))
    .(STEPS)
  })

  template_FUN <- bquote_compile(function(..., .progressr_progressor) {
    on.exit(.progressr_progressor())
    .(FUN)(...)
  })

  template_expr <- bquote_compile(local({
    on.exit(.progressr_progressor())
    .(EXPR)
  }))

  function(expr, fcn_name, fcn, ..., envir = parent.frame()) {
    names <- names(expr)
    if (is.null(names)) names <- rep("", length.out = length(expr))
    names <- names[-1]
    target_names <- names(formals(fcn))[seq_along(names)]
    unnamed <- setdiff(target_names, names)
    ddd <- which(unnamed == "...")
    if (length(ddd) > 0L) {
      stopifnot(length(ddd) == 1L)
      unnamed <- unnamed[seq_len(ddd - 1L)]
    }
    names[names == ""] <- unnamed
    names <- c("", names)

    idx_X <- idx_data <- idx_FUN <- idx_n <- idx_expr <- NULL

    if (fcn_name %in% c("future_by")) {
      idx_data <- which(names == "data")
      idx_FUN <- which(names == "FUN")
    } else if (fcn_name %in% c("future_eapply")) {
      idx_X <- which(names == "env")
      idx_FUN <- which(names == "FUN")
    } else if (fcn_name %in% c("future_lapply", "future_sapply", "future_vapply")) {
      idx_X <- which(names == "X")
      idx_FUN <- which(names == "FUN")
    } else if (fcn_name %in% c("future_replicate")) {
      idx_n <- which(names == "n")
      idx_expr <- which(names == "expr")
    } else {
      idx_FUN <- which(names == "FUN")
    }

    parts <- as.list(expr)

    if (!is.null(idx_X)) {
      stopifnot(length(idx_X) == 1L)
      parts[[idx_X]] <- bquote_apply(template_along, ALONG = parts[[idx_X]])
    }

    if (!is.null(idx_data)) {
      stopifnot(length(idx_data) == 1L)
      parts[[idx_data]] <- bquote_apply(template_steps_nrow, DATA = parts[[idx_data]])
    }

    if (!is.null(idx_FUN)) {
      stopifnot(length(idx_FUN) == 1L)
      FUN <- expr[[idx_FUN]]
      parts[[idx_FUN]] <- bquote_apply(template_FUN, FUN = FUN)

      progressr_args <- list(
        .progressr_progressor = quote(.progressr_progressor)
      )
      parts <- c(parts, progressr_args)
    }

    if (!is.null(idx_n)) {
      stopifnot(length(idx_n) == 1L)
      parts[[idx_n]] <- bquote_apply(template_steps, STEPS = parts[[idx_n]])
    }

    if (!is.null(idx_expr)) {
      stopifnot(length(idx_expr) == 1L)
      parts[[idx_expr]] <- bquote_apply(template_expr, EXPR = expr[[idx_expr]])
    }

    bquote(local(.(as.call(parts))))
  } ## progressify_future.apply()
})


append_builtin_transpilers_for_future.apply <- local({
  known_fcns <- list(
    future_apply = c,
    future_by = c,
    future_eapply = c,             ## done
    future_lapply = c,             ## done
    future_.mapply = c,
    future_mapply = c,
    future_Map = c,
    future_replicate = c,          ## done
    future_sapply = c,             ## done
    future_tapply = c,
    future_vapply = c              ## done
  )

  template <- bquote_compile(function(expr, options) {
    ns <- getNamespace("future.apply")
    fcn <- get(.(fcn_name), mode = "function", envir = ns)
    progressify_future.apply(expr, fcn_name = .(fcn_name), fcn = fcn, envir = parent.frame())
  })

  make_transpiler <- function(fcn_name) {
    transpiler <- eval(bquote_apply(template))
    eval(transpiler)
  }

  function() {
    ## future.apply::future_apply(), ...
    transpilers <- list()
    for (fcn_name in names(known_fcns)) {
      transpilers[[fcn_name]] <- list(
        label = sprintf("future.apply::%s() transpiler", fcn_name),
        transpiler = make_transpiler(fcn_name)
      )
    } ## for (fcn_name ...)
    transpilers <- list(future.apply = transpilers)

    append_transpilers("progressify::built-in", transpilers)

    ## Return required packages
    c("future.apply", "progressr")
  }
})
