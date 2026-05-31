# crossmap::xmap(.l = xs, .f = FUN, ...) =>
#
# local(
#   crossmap::xmap(.l = {
#       .progressr_progressor <- progressr::progressor(
#         steps = prod(lengths(xs)))
#       xs
#     },
#     .f = local({
#       .progressr_f <- purrr::as_mapper(FUN)
#       function(..., .progressr_progressor) {
#         on.exit(.progressr_progressor())
#         .progressr_f(...)
#       }
#     }), .progressr_progressor = .progressr_progressor)
# )
#
progressify_crossmap <- local({
  ## xmap-style: number of iterations = product of all element lengths
  template_steps_prod_lengths <- bquote_compile({
    .progressr_progressor <- progressr::progressor(
      steps = prod(lengths(.(DATA))))
    .(DATA)
  })

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
    empty_idxs <- which(names == "")
    n <- min(length(empty_idxs), length(unnamed))
    if (n > 0L) names[empty_idxs[seq_len(n)]] <- unnamed[seq_len(n)]
    names <- c("", names)

    idx_x <- idx_l <- idx_f <- NULL

    if (fcn_name %in% c("xmap", "xmap_chr", "xmap_dbl", "xmap_int",
                          "xmap_lgl", "xmap_vec",
                          "xmap_dfc", "xmap_dfr",
                          "xmap_mat", "xmap_arr",
                          "xwalk",
                          "future_xmap", "future_xmap_chr",
                          "future_xmap_dbl", "future_xmap_int",
                          "future_xmap_lgl", "future_xmap_vec",
                          "future_xmap_dfc", "future_xmap_dfr",
                          "future_xmap_mat", "future_xmap_arr",
                          "future_xmap_raw",
                          "future_xwalk")) {
      ## xmap-style: .l + .f, cross-product iteration
      idx_l <- which(names == ".l")
      idx_f <- which(names == ".f")
    } else if (fcn_name %in% c("pmap_vec", "future_pmap_vec")) {
      ## pmap-style: .l + .f, parallel iteration
      idx_l <- which(names == ".l")
      idx_f <- which(names == ".f")
    } else if (fcn_name %in% c("map2_vec", "future_map2_vec")) {
      ## map2-style: .x + .f
      idx_x <- which(names == ".x")
      idx_f <- which(names == ".f")
    } else {
      ## map/imap-style: .x + .f
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
      if (fcn_name %in% c("xmap", "xmap_chr", "xmap_dbl", "xmap_int",
                            "xmap_lgl", "xmap_vec",
                            "xmap_dfc", "xmap_dfr",
                            "xmap_mat", "xmap_arr",
                            "xwalk",
                            "future_xmap", "future_xmap_chr",
                            "future_xmap_dbl", "future_xmap_int",
                            "future_xmap_lgl", "future_xmap_vec",
                            "future_xmap_dfc", "future_xmap_dfr",
                            "future_xmap_mat", "future_xmap_arr",
                            "future_xmap_raw",
                            "future_xwalk")) {
        ## xmap: cross-product, so steps = prod(lengths(.l))
        parts[[idx_l]] <- bquote_apply(template_steps_prod_lengths,
                                        DATA = parts[[idx_l]])
      } else {
        ## pmap_vec: parallel, so along = .l[[1]]
        parts[[idx_l]] <- bquote_apply(template_along_first,
                                        ALONG = parts[[idx_l]])
      }
    }

    if (!is.null(idx_f)) {
      stopifnot(length(idx_f) == 1L)
      FUN <- expr[[idx_f]]
      parts[[idx_f]] <- bquote_apply(template_f, FUN = FUN)

      progressr_args <- list(
        .progressr_progressor = quote(.progressr_progressor)
      )
      parts <- c(parts, progressr_args)
    }

    bquote(local(.(as.call(parts))))
  } ## progressify_crossmap()
})


append_builtin_transpilers_for_crossmap <- local({
  known_fcns <- list(
    ## purrr-extensions
    imap_vec = c,
    map_vec = c,
    map2_vec = c,
    pmap_vec = c,
    ## xmap family
    xmap = c,
    xmap_chr = c,
    xmap_dbl = c,
    xmap_int = c,
    xmap_lgl = c,
    xmap_vec = c,
    xmap_dfc = c,
    xmap_dfr = c,
    xmap_mat = c,
    xmap_arr = c,
    xwalk = c,
    ## future purrr-extensions
    future_imap_vec = c,
    future_map_vec = c,
    future_map2_vec = c,
    future_pmap_vec = c,
    ## future xmap family
    future_xmap = c,
    future_xmap_chr = c,
    future_xmap_dbl = c,
    future_xmap_int = c,
    future_xmap_lgl = c,
    future_xmap_vec = c,
    future_xmap_dfc = c,
    future_xmap_dfr = c,
    future_xmap_mat = c,
    future_xmap_arr = c,
    future_xmap_raw = c,
    future_xwalk = c
  )

  template <- bquote_compile(function(expr, options) {
    ns <- getNamespace("crossmap")
    fcn <- get(.(fcn_name), mode = "function", envir = ns)
    progressify_crossmap(expr, fcn_name = .(fcn_name), fcn = fcn, envir = parent.frame())
  })

  make_transpiler <- function(fcn_name) {
    transpiler <- eval(bquote_apply(template))
    eval(transpiler)
  }

  function() {
    ## crossmap::xmap(), ...
    transpilers <- list()
    for (fcn_name in names(known_fcns)) {
      transpilers[[fcn_name]] <- list(
        label = sprintf("crossmap::%s() transpiler", fcn_name),
        transpiler = make_transpiler(fcn_name)
      )
    } ## for (fcn_name ...)
    transpilers <- list(crossmap = transpilers)

    append_transpilers("progressify::built-in", transpilers)

    ## Return required packages
    c("crossmap", "progressr")
  }
})
