# plyr::llply(.data = xs, .fun = FUN, ...) =>
#
# local(
#   plyr::llply(.data = {
#       .progressr_progressor <- progressr::progressor(along = xs)
#       xs
#     },
#     .fun = function(..., .progressr_progressor) {
#       on.exit(.progressr_progressor())
#       FUN(...)
#     }, .progressr_progressor = .progressr_progressor)
# )
#
progressify_plyr <- local({
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

    idx_data <- idx_fun <- idx_n <- idx_expr <- NULL

    if (fcn_name %in% c("llply", "ldply", "laply", "l_ply")) {
      idx_data <- which(names == ".data")
      idx_fun <- which(names == ".fun")
    } else if (fcn_name %in% c("mlply", "mdply", "maply", "m_ply")) {
      idx_data <- which(names == ".data")
      idx_fun <- which(names == ".fun")
    } else if (fcn_name %in% c("rlply", "rdply", "raply", "r_ply")) {
      idx_n <- which(names == ".n")
      idx_expr <- which(names == ".expr")
    }

    parts <- as.list(expr)

    if (!is.null(idx_data)) {
      stopifnot(length(idx_data) == 1L)
      if (fcn_name %in% c("mlply", "mdply", "maply", "m_ply")) {
        parts[[idx_data]] <- bquote_apply(template_steps_nrow, DATA = parts[[idx_data]])
      } else {
        parts[[idx_data]] <- bquote_apply(template_along, ALONG = parts[[idx_data]])
      }
    }

    if (!is.null(idx_fun)) {
      stopifnot(length(idx_fun) == 1L)
      FUN <- expr[[idx_fun]]
      parts[[idx_fun]] <- bquote_apply(template_FUN, FUN = FUN)

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
  } ## progressify_plyr()
})


append_builtin_transpilers_for_plyr <- local({
  known_fcns <- list(
    llply = c,
    ldply = c,
    laply = c,
    l_ply = c,
    mlply = c,
    mdply = c,
    maply = c,
    m_ply = c,
    rlply = c,
    rdply = c,
    raply = c,
    r_ply = c
  )

  template <- bquote_compile(function(expr, options) {
    ns <- getNamespace("plyr")
    fcn <- get(.(fcn_name), mode = "function", envir = ns)
    progressify_plyr(expr, fcn_name = .(fcn_name), fcn = fcn, envir = parent.frame())
  })

  make_transpiler <- function(fcn_name) {
    transpiler <- eval(bquote_apply(template))
    eval(transpiler)
  }

  function() {
    ## plyr::llply(), ...
    transpilers <- list()
    for (fcn_name in names(known_fcns)) {
      transpilers[[fcn_name]] <- list(
        label = sprintf("plyr::%s() transpiler", fcn_name),
        transpiler = make_transpiler(fcn_name)
      )
    } ## for (fcn_name ...)
    transpilers <- list(plyr = transpilers)

    append_transpilers("progressify::built-in", transpilers)

    ## Return required packages
    c("plyr", "progressr")
  }
})
