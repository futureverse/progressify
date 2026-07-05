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
    ## mapply(), Map(), and .mapply() iterate over '...'. We need to wrap
    ## FUN() as a closure capturing the progressor from the enclosing
    ## local() environment.
    if (fcn_name %in% c("mapply", "Map", ".mapply")) {
      return(progressify_base_mapply(expr, fcn_name = fcn_name, fcn = fcn))
    }

    names <- names(expr)
    if (is.null(names)) names <- rep("", length.out = length(expr))
    names <- names[-1]
    target_names <- names(formals(fcn))[seq_along(names)]
    unnamed <- setdiff(target_names, names)
    names[names == ""] <- unnamed
    names <- c("", names)

    idx_X <- idx_data <- idx_FUN <- idx_n <- idx_expr <- NULL

    if (fcn_name %in% c("by")) {
      idx_data <- which(names == "data")
      idx_FUN <- which(names == "FUN")
    } else if (fcn_name %in% c("eapply")) {
      idx_X <- which(names == "env")
      idx_FUN <- which(names == "FUN")
    } else if (fcn_name %in% c("lapply", "sapply", "vapply")) {
      idx_X <- which(names == "X")
      idx_FUN <- which(names == "FUN")
    } else if (fcn_name %in% c("replicate")) {
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
        ...FUN = FUN,
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
  } ## progressify_base()
})


# mapply(FUN = FUN, ..., MoreArgs, SIMPLIFY, USE.NAMES) =>
#
# local({
#   ...FUN <- FUN
#   mapply(FUN = function(...) {
#     on.exit(.progressr_progressor())
#     ...FUN(...)
#   }, {
#     .progressr_progressor <- progressr::progressor(along = ..1)
#     ..1
#   }, ..2, MoreArgs = MoreArgs, ...)
# })
#
progressify_base_mapply <- local({
  function(expr, fcn_name, fcn) {
    mc <- match.call(fcn, call = expr)
    parts <- as.list(mc)
    names <- names(parts)
    if (is.null(names)) names <- rep("", length.out = length(parts))

    fun_arg <- if (fcn_name == "Map") "f" else "FUN"
    idx_FUN <- which(names == fun_arg)
    ## FUN may be passed positionally as the first argument
    if (length(idx_FUN) == 0L) idx_FUN <- 2L
    stopifnot(length(idx_FUN) == 1L)

    orig_FUN <- parts[[idx_FUN]]

    ## Wrap FUN as a closure that captures '...FUN' and '.progressr_progressor'
    ## from the enclosing local() environment.
    parts[[idx_FUN]] <- bquote_apply(template_FUN_closure)
    names[idx_FUN] <- fun_arg

    if (fcn_name == ".mapply") {
      ## .mapply(FUN, dots, MoreArgs): 'dots' is the list of vectors to map
      idx_dots <- which(names == "dots")
      if (length(idx_dots) == 0L) {
        idx_dots <- setdiff(seq_along(parts)[-1L], idx_FUN)[1L]
      }
      stopifnot(length(idx_dots) == 1L, !is.na(idx_dots))
      parts[[idx_dots]] <- bquote_apply(template_along_first,
                                        ALONG = parts[[idx_dots]])
    } else {
      ## mapply()/Map(): the '...' elements are the vectors to map over
      reserved <- c(fun_arg, "MoreArgs", "SIMPLIFY", "USE.NAMES")
      idx_dots <- setdiff(seq_along(parts)[-1L], idx_FUN)
      idx_dots <- idx_dots[!(names[idx_dots] %in% reserved)]
      stopifnot(length(idx_dots) >= 1L)
      idx_first <- idx_dots[1L]
      parts[[idx_first]] <- bquote_apply(template_along,
                                         ALONG = parts[[idx_first]])
    }

    names(parts) <- names
    call <- as.call(parts)

    bquote(local({
      ...FUN <- .(orig_FUN)
      .(call)
    }))
  } ## progressify_base_mapply()
})


append_builtin_transpilers_for_base <- local({
  known_fcns <- list(
    apply = c,
    by = c,
    eapply = c,             ## done
    lapply = c,             ## done
    .mapply = c,
    mapply = c,
    Map = c,
    replicate = c,          ## done
    sapply = c,             ## done
    tapply = c,
    vapply = c              ## done
  )

  template <- bquote_compile(function(expr, options) {
    ns <- baseenv()
    fcn <- get(.(fcn_name), mode = "function", envir = ns)
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
