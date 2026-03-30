# purrr::map(.x = xs, .f = FUN, ...) =>
#
# local(
#   purrr::map(.x = { .progressr_progressor <- progressr::progressor(along = xs); xs },
#     .f = local({
#       .progressr_f <- purrr::as_mapper(FUN)
#       function(..., .progressr_progressor) {
#         on.exit(.progressr_progressor())
#         .progressr_f(...)
#       }
#     }), .progressr_progressor = .progressr_progressor)
# )
#
progressify_purrr <- local({
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

    idx_x <- idx_l <- idx_f <- NULL

    if (fcn_name %in% c("pmap", "pmap_lgl", "pmap_int", "pmap_dbl",
                         "pmap_chr", "pmap_vec", "pwalk")) {
      idx_l <- which(names == ".l")
      idx_f <- which(names == ".f")
    } else if (fcn_name %in% c("map2", "map2_lgl", "map2_int", "map2_dbl",
                                "map2_chr", "map2_vec", "walk2",
                                "modify2")) {
      idx_x <- which(names == ".x")
      idx_f <- which(names == ".f")
    } else {
      idx_x <- which(names == ".x")
      idx_f <- which(names == ".f")
    }

    parts <- as.list(expr)

    if (!is.null(idx_x)) {
      stopifnot(length(idx_x) == 1L)
      parts[[idx_x]] <- bquote_apply(template_along, ALONG = parts[[idx_x]])
    }

    if (!is.null(idx_l)) {
      stopifnot(length(idx_l) == 1L)
      parts[[idx_l]] <- bquote_apply(template_along_first, ALONG = parts[[idx_l]])
    }

    if (!is.null(idx_f)) {
      stopifnot(length(idx_f) == 1L)
      FUN <- expr[[idx_f]]
      ## NOTE: purrr's .f can be a function, formula, string, or integer,
      ## so we use purrr::as_mapper() to convert it to a callable function
      parts[[idx_f]] <- bquote_apply(template_f, FUN = FUN)

      progressr_args <- list(
        .progressr_progressor = quote(.progressr_progressor)
      )
      parts <- c(parts, progressr_args)
    }

    bquote(local(.(as.call(parts))))
  } ## progressify_purrr()
})


append_builtin_transpilers_for_purrr <- local({
  known_fcns <- list(
    map = c,
    map_lgl = c,
    map_int = c,
    map_dbl = c,
    map_chr = c,
    map_vec = c,
    walk = c,
    map2 = c,
    map2_lgl = c,
    map2_int = c,
    map2_dbl = c,
    map2_chr = c,
    map2_vec = c,
    walk2 = c,
    pmap = c,
    pmap_lgl = c,
    pmap_int = c,
    pmap_dbl = c,
    pmap_chr = c,
    pmap_vec = c,
    pwalk = c,
    imap = c,
    imap_lgl = c,
    imap_int = c,
    imap_dbl = c,
    imap_chr = c,
    modify = c,
    modify2 = c,
    imodify = c
  )

  template <- bquote_compile(function(expr, options) {
    ns <- getNamespace("purrr")
    fcn <- get(.(fcn_name), mode = "function", envir = ns)
    progressify_purrr(expr, fcn_name = .(fcn_name), fcn = fcn, envir = parent.frame())
  })

  make_transpiler <- function(fcn_name) {
    transpiler <- eval(bquote_apply(template))
    eval(transpiler)
  }

  function() {
    ## purrr::map(), ...
    transpilers <- list()
    for (fcn_name in names(known_fcns)) {
      transpilers[[fcn_name]] <- list(
        label = sprintf("purrr::%s() transpiler", fcn_name),
        transpiler = make_transpiler(fcn_name)
      )
    } ## for (fcn_name ...)
    transpilers <- list(purrr = transpilers)

    append_transpilers("progressify::built-in", transpilers)

    ## Return required packages
    c("purrr", "progressr")
  }
})
