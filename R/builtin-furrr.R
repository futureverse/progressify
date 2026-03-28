# furrr::future_map(.x = xs, .f = FUN, ...) =>
#
# local(
#   furrr::future_map(.x = { .progressr_progressor <- progressr::progressor(along = xs); xs },
#     .f = local({
#       .progressr_f <- purrr::as_mapper(FUN)
#       function(..., .progressr_progressor) {
#         on.exit(.progressr_progressor())
#         .progressr_f(...)
#       }
#     }), .progressr_progressor = .progressr_progressor)
# )
#
progressify_furrr <- local({
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

    if (fcn_name %in% c("future_pmap", "future_pmap_lgl", "future_pmap_int",
                         "future_pmap_dbl", "future_pmap_chr", "future_pmap_raw",
                         "future_pmap_dfr", "future_pmap_dfc",
                         "future_pwalk")) {
      idx_l <- which(names == ".l")
      idx_f <- which(names == ".f")
    } else if (fcn_name %in% c("future_map2", "future_map2_lgl",
                                "future_map2_int", "future_map2_dbl",
                                "future_map2_chr", "future_map2_raw",
                                "future_map2_dfr", "future_map2_dfc",
                                "future_walk2")) {
      idx_x <- which(names == ".x")
      idx_f <- which(names == ".f")
    } else {
      idx_x <- which(names == ".x")
      idx_f <- which(names == ".f")
    }

    parts <- as.list(expr)

    if (!is.null(idx_x)) {
      stopifnot(length(idx_x) == 1L)
      parts[[idx_x]] <- bquote({
        .progressr_progressor <- progressr::progressor(along = .(parts[[idx_x]]))
        .(parts[[idx_x]])
      })
    }

    if (!is.null(idx_l)) {
      stopifnot(length(idx_l) == 1L)
      parts[[idx_l]] <- bquote({
        .progressr_progressor <- progressr::progressor(along = .(parts[[idx_l]])[[1]])
        .(parts[[idx_l]])
      })
    }

    if (!is.null(idx_f)) {
      stopifnot(length(idx_f) == 1L)
      FUN <- expr[[idx_f]]
      ## NOTE: furrr's .f can be a function, formula, string, or integer,
      ## so we use purrr::as_mapper() to convert it to a callable function
      t_f <- bquote(local({
        .progressr_f <- purrr::as_mapper(.(FUN))
        function(..., .progressr_progressor) {
          on.exit(.progressr_progressor())
          .progressr_f(...)
        }
      }))
      parts[[idx_f]] <- t_f

      progressr_args <- list(
        .progressr_progressor = quote(.progressr_progressor)
      )
      parts <- c(parts, progressr_args)
    }

    bquote(local(.(as.call(parts))))
  } ## progressify_furrr()
})


append_builtin_transpilers_for_furrr <- local({
  known_fcns <- list(
    future_map = c,
    future_map_lgl = c,
    future_map_int = c,
    future_map_dbl = c,
    future_map_chr = c,
    future_map_raw = c,
    future_map_dfr = c,
    future_map_dfc = c,
    future_map_at = c,
    future_map_if = c,
    future_walk = c,
    future_map2 = c,
    future_map2_lgl = c,
    future_map2_int = c,
    future_map2_dbl = c,
    future_map2_chr = c,
    future_map2_raw = c,
    future_map2_dfr = c,
    future_map2_dfc = c,
    future_walk2 = c,
    future_pmap = c,
    future_pmap_lgl = c,
    future_pmap_int = c,
    future_pmap_dbl = c,
    future_pmap_chr = c,
    future_pmap_raw = c,
    future_pmap_dfr = c,
    future_pmap_dfc = c,
    future_pwalk = c,
    future_imap = c,
    future_imap_lgl = c,
    future_imap_int = c,
    future_imap_dbl = c,
    future_imap_chr = c,
    future_imap_raw = c,
    future_imap_dfr = c,
    future_imap_dfc = c,
    future_iwalk = c,
    future_modify = c,
    future_modify_at = c,
    future_modify_if = c
  )

  template <- bquote_compile(function(expr, options) {
    ns <- getNamespace("furrr")
    fcn <- get(.(fcn_name), mode = "function", envir = ns)
    progressify_furrr(expr, fcn_name = .(fcn_name), fcn = fcn, envir = parent.frame())
  })

  make_transpiler <- function(fcn_name) {
    transpiler <- eval(bquote_apply(template))
    eval(transpiler)
  }

  function() {
    ## furrr::future_map(), ...
    transpilers <- list()
    for (fcn_name in names(known_fcns)) {
      transpilers[[fcn_name]] <- list(
        label = sprintf("furrr::%s() transpiler", fcn_name),
        transpiler = make_transpiler(fcn_name)
      )
    } ## for (fcn_name ...)
    transpilers <- list(furrr = transpilers)

    append_transpilers("progressify::built-in", transpilers)

    ## Return required packages
    c("furrr", "progressr")
  }
})
