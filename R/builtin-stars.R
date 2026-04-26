# stars::st_apply(X = x, MARGIN = m, FUN = f, ...) =>
#
# local(
#   stars::st_apply(X = {
#       .progressr_X <- x
#       .progressr_MARGIN <- m
#       .progressr_single_arg <- <single_arg from call or NULL>
#       if (is.null(.progressr_single_arg)) .progressr_single_arg <- TRUE
#       .progressr_steps <- if (.progressr_single_arg) {
#         .progressr_dims <- dim(.progressr_X)
#         if (is.character(.progressr_MARGIN)) {
#           .progressr_MARGIN <- match(.progressr_MARGIN, names(.progressr_dims))
#         }
#         length(.progressr_X) * prod(.progressr_dims[.progressr_MARGIN])
#       } else {
#         length(.progressr_X)
#       }
#       .progressr_progressor <- progressr::progressor(steps = .progressr_steps)
#       .progressr_X
#     }, MARGIN = m, FUN = function(...) {
#       on.exit(.progressr_progressor())
#       f(...)
#     }, .fname = <deparse1(f)>, PROGRESS = FALSE)
# )
#
progressify_stars <- local({
  ## Pre-compiled bquote templates
  template_steps_stars <- bquote_compile({
    .progressr_X <- .(X)
    .progressr_MARGIN <- .(MARGIN)
    .progressr_single_arg <- .(SINGLE_ARG)
    if (is.null(.progressr_single_arg)) {
      .progressr_single_arg <- TRUE
    }
    
    .progressr_steps <- if (.progressr_single_arg) {
      .progressr_dims <- dim(.progressr_X)
      if (is.character(.progressr_MARGIN)) {
        .progressr_MARGIN <- match(.progressr_MARGIN, names(.progressr_dims))
      }
      length(.progressr_X) * prod(.progressr_dims[.progressr_MARGIN])
    } else {
      length(.progressr_X)
    }
    .progressr_progressor <- progressr::progressor(steps = .progressr_steps)
    .progressr_X
  })

  ## Closure-based FUN wrapper (captures .progressr_progressor from environment)
  template_FUN_stars <- bquote_compile(function(...) {
    on.exit(.progressr_progressor())
    .(FUN)(...)
  })

  function(expr, fcn_name, fcn, ..., envir = parent.frame()) {
    names <- names(expr)
    if (is.null(names)) names <- rep("", length.out = length(expr))
    names <- names[-1]
    target_names <- names(formals(fcn))[seq_along(names)]
    unnamed <- setdiff(target_names, names)
    ## Handle '...' in formals - only resolve positional args before it
    ddd <- which(unnamed == "...")
    if (length(ddd) > 0L) {
      stopifnot(length(ddd) == 1L)
      unnamed <- unnamed[seq_len(ddd - 1L)]
    }
    empty_idxs <- which(names == "")
    n <- min(length(empty_idxs), length(unnamed))
    if (n > 0L) names[empty_idxs[seq_len(n)]] <- unnamed[seq_len(n)]
    names <- c("", names)

    idx_X <- which(names == "X")
    idx_MARGIN <- which(names == "MARGIN")
    idx_FUN <- which(names == "FUN")
    idx_single_arg <- which(names == "single_arg")

    parts <- as.list(expr)

    if (length(idx_X) == 1L && length(idx_MARGIN) == 1L) {
      SINGLE_ARG <- if (length(idx_single_arg) == 1L) expr[[idx_single_arg]] else NULL
      parts[[idx_X]] <- bquote_apply(template_steps_stars, 
                                     X = parts[[idx_X]], 
                                     MARGIN = parts[[idx_MARGIN]],
                                     SINGLE_ARG = SINGLE_ARG)
    }

    if (length(idx_FUN) == 1L) {
      FUN <- expr[[idx_FUN]]
      parts[[idx_FUN]] <- bquote_apply(template_FUN_stars, FUN = FUN)
      
      ## Preserve original function name for stars
      if (!".fname" %in% names) {
        parts[[".fname"]] <- deparse1(FUN)
      }
      
      ## Disable internal progress bar
      if (!"PROGRESS" %in% names) {
        parts[["PROGRESS"]] <- FALSE
      }
    }

    bquote(local(.(as.call(parts))))
  } ## progressify_stars()
})


append_builtin_transpilers_for_stars <- local({
  known_fcns <- list(
    st_apply = c
  )

  template <- bquote_compile(function(expr, options) {
    ns <- getNamespace("stars")
    fcn <- get(.(fcn_name), mode = "function", envir = ns)
    progressify_stars(expr, fcn_name = .(fcn_name), fcn = fcn, envir = parent.frame())
  })

  make_transpiler <- function(fcn_name) {
    transpiler <- eval(bquote_apply(template))
    eval(transpiler)
  }

  function() {
    ## stars::st_apply()
    transpilers <- list()
    for (fcn_name in names(known_fcns)) {
      transpilers[[fcn_name]] <- list(
        label = sprintf("stars::%s() transpiler", fcn_name),
        transpiler = make_transpiler(fcn_name)
      )
    } ## for (fcn_name ...)
    transpilers <- list(stars = transpilers)

    append_transpilers("progressify::built-in", transpilers)

    ## Return required packages
    c("stars", "progressr")
  }
})
