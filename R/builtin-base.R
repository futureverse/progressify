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
      return(progressify_mapply_family(expr, fcn_name = fcn_name, fcn = fcn))
    }

    ## apply() iterates over the margins of 'X'; the number of iterations
    ## depends on both 'X' and 'MARGIN' rather than on a single argument.
    if (fcn_name == "apply") {
      return(progressify_apply_family(expr, fcn_name = fcn_name, fcn = fcn))
    }

    ## tapply() applies FUN to each non-empty group of 'X' defined by 'INDEX';
    ## the number of iterations is the number of non-empty group combinations.
    if (fcn_name == "tapply") {
      return(progressify_tapply_family(expr, fcn_name = fcn_name, fcn = fcn))
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
# Shared by base's mapply()/Map()/.mapply() and future.apply's
# future_mapply()/future_Map()/future_.mapply(), which all iterate over their
# '...' (or 'dots') elements and therefore cannot thread the progressor to FUN
# via '...'.  Instead, FUN is wrapped as a closure that captures '...FUN' and
# '.progressr_progressor' from the enclosing local() environment.
progressify_mapply_family <- local({
  function(expr, fcn_name, fcn) {
    ## match.call() resolves named formals (FUN/f, MoreArgs, dots, and any
    ## future.* arguments) while leaving the elements to iterate over in place.
    mc <- match.call(fcn, call = expr)
    parts <- as.list(mc)
    names <- names(parts)
    if (is.null(names)) names <- rep("", length.out = length(parts))

    ## Map()/future_Map() name their function 'f'; the rest use 'FUN'
    is_Map <- grepl("(^|_)Map$", fcn_name)
    is_dotmapply <- grepl("[.]mapply$", fcn_name)
    fun_arg <- if (is_Map) "f" else "FUN"

    idx_FUN <- which(names == fun_arg)
    ## FUN may be passed positionally as the first argument
    if (length(idx_FUN) == 0L) idx_FUN <- 2L
    stopifnot(length(idx_FUN) == 1L)

    orig_FUN <- parts[[idx_FUN]]

    ## Wrap FUN as a closure that captures '...FUN' and '.progressr_progressor'
    ## from the enclosing local() environment.
    parts[[idx_FUN]] <- bquote_apply(template_FUN_closure)
    names[idx_FUN] <- fun_arg

    if (is_dotmapply) {
      ## .mapply(FUN, dots, MoreArgs): 'dots' is the list of vectors to map
      idx_dots <- which(names == "dots")
      if (length(idx_dots) == 0L) {
        idx_dots <- setdiff(seq_along(parts)[-1L], idx_FUN)[1L]
      }
      stopifnot(length(idx_dots) == 1L, !is.na(idx_dots))
      parts[[idx_dots]] <- bquote_apply(template_along_first,
                                        ALONG = parts[[idx_dots]])
    } else {
      ## mapply()/Map(): the '...' elements are the vectors to map over.
      ## Everything matched to a named formal (FUN/f, MoreArgs, SIMPLIFY,
      ## USE.NAMES, future.*, ...) is reserved; the first remaining argument
      ## is the first vector to iterate over.
      reserved <- setdiff(names(formals(fcn)), "...")
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
  } ## progressify_mapply_family()
})


# apply(X = X, MARGIN = MARGIN, FUN = FUN, ..., simplify) =>
#
# local({
#   ...FUN <- FUN
#   .progressr_X <- X
#   .progressr_MARGIN <- MARGIN
#   .progressr_progressor <- progressr::progressor(
#     steps = prod(dim(.progressr_X)[.progressr_MARGIN])
#   )
#   apply(X = .progressr_X, MARGIN = .progressr_MARGIN, FUN = function(...) {
#     on.exit(.progressr_progressor())
#     ...FUN(...)
#   }, ...)
# })
#
# apply() calls FUN exactly prod(dim(X)[MARGIN]) times and forwards its '...'
# to FUN.  'X' and 'MARGIN' are captured once to avoid double evaluation and so
# that the step count can be computed from both.  FUN is wrapped as a closure
# that captures '...FUN' and '.progressr_progressor' from the enclosing local()
# environment.
#
# Shared by base's apply() and future.apply's future_apply(), which have the
# same signature and '...'-forwarding behaviour (future.* arguments stay named
# via match.call() and are preserved in the rebuilt call).
progressify_apply_family <- local({
  function(expr, fcn_name, fcn) {
    mc <- match.call(fcn, call = expr)
    parts <- as.list(mc)
    names <- names(parts)
    if (is.null(names)) names <- rep("", length.out = length(parts))

    idx_X      <- which(names == "X")
    idx_MARGIN <- which(names == "MARGIN")
    idx_FUN    <- which(names == "FUN")
    stopifnot(length(idx_X) == 1L, length(idx_MARGIN) == 1L,
              length(idx_FUN) == 1L)

    orig_X      <- parts[[idx_X]]
    orig_MARGIN <- parts[[idx_MARGIN]]
    orig_FUN    <- parts[[idx_FUN]]

    ## Refer to the captured copies inside the rebuilt call, and wrap FUN as a
    ## closure capturing '...FUN' and '.progressr_progressor'.
    parts[[idx_X]]      <- quote(.progressr_X)
    parts[[idx_MARGIN]] <- quote(.progressr_MARGIN)
    parts[[idx_FUN]]    <- bquote_apply(template_FUN_closure)

    call <- as.call(parts)

    bquote(local({
      ...FUN <- .(orig_FUN)
      .progressr_X <- .(orig_X)
      .progressr_MARGIN <- .(orig_MARGIN)
      .progressr_progressor <- progressr::progressor(steps = {
        .progressr_m <- .progressr_MARGIN
        ## MARGIN may be given as dimnames names, cf. apply()
        if (is.character(.progressr_m)) {
          .progressr_m <- match(.progressr_m, names(dimnames(.progressr_X)))
        }
        prod(dim(.progressr_X)[.progressr_m])
      })
      .(call)
    }))
  } ## progressify_apply_family()
})


# tapply(X = X, INDEX = INDEX, FUN = FUN, ..., default, simplify) =>
#
# local({
#   ...FUN <- FUN
#   .progressr_X <- X
#   .progressr_INDEX <- INDEX
#   .progressr_progressor <- progressr::progressor(
#     steps = nlevels(interaction(as.list(.progressr_INDEX), drop = TRUE))
#   )
#   tapply(X = .progressr_X, INDEX = .progressr_INDEX, FUN = function(...) {
#     on.exit(.progressr_progressor())
#     ...FUN(...)
#   }, ...)
# })
#
# tapply() calls FUN once per non-empty group combination of 'INDEX' and
# forwards its '...' to FUN.  The step count equals the number of non-empty
# group combinations, i.e. nlevels(interaction(INDEX, drop = TRUE)).  'X' and
# 'INDEX' are captured once (INDEX is referenced both when computing the step
# count and in the call).  FUN is wrapped as a closure that captures '...FUN'
# and '.progressr_progressor' from the enclosing local() environment.
#
# Shared by base's tapply() and future.apply's future_tapply().
progressify_tapply_family <- local({
  function(expr, fcn_name, fcn) {
    mc <- match.call(fcn, call = expr)
    parts <- as.list(mc)
    names <- names(parts)
    if (is.null(names)) names <- rep("", length.out = length(parts))

    ## FUN is optional in tapply(); without it (or with FUN = NULL) there is no
    ## iteration to report progress on, so leave the call untouched.
    idx_FUN <- which(names == "FUN")
    if (length(idx_FUN) != 1L || is.null(parts[[idx_FUN]])) {
      return(expr)
    }

    idx_X     <- which(names == "X")
    idx_INDEX <- which(names == "INDEX")
    stopifnot(length(idx_X) == 1L, length(idx_INDEX) == 1L)

    orig_X     <- parts[[idx_X]]
    orig_INDEX <- parts[[idx_INDEX]]
    orig_FUN   <- parts[[idx_FUN]]

    ## Refer to the captured copies inside the rebuilt call, and wrap FUN as a
    ## closure capturing '...FUN' and '.progressr_progressor'.
    parts[[idx_X]]     <- quote(.progressr_X)
    parts[[idx_INDEX]] <- quote(.progressr_INDEX)
    parts[[idx_FUN]]   <- bquote_apply(template_FUN_closure)

    call <- as.call(parts)

    bquote(local({
      ...FUN <- .(orig_FUN)
      .progressr_X <- .(orig_X)
      .progressr_INDEX <- .(orig_INDEX)
      .progressr_progressor <- progressr::progressor(steps = {
        .progressr_idx <- .progressr_INDEX
        if (!is.list(.progressr_idx)) .progressr_idx <- list(.progressr_idx)
        nlevels(interaction(.progressr_idx, drop = TRUE))
      })
      .(call)
    }))
  } ## progressify_tapply_family()
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
