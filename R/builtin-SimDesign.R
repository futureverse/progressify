# SimDesign::runSimulation(...) =>
#
# local({
#   design <- MyDesign
#   replications <- 10
#   .progressr_steps <- if (length(replications) == 1L) replications * nrow(design) else sum(replications)
#   .progressr_progressor <- progressr::progressor(steps = .progressr_steps)
#   .progressr_analyse <- Anal
#   SimDesign::runSimulation(
#     design = design,
#     replications = replications,
#     generate = generate,
#     analyse = function(condition, dat, fixed_objects = NULL, ...) {
#       on.exit(.progressr_progressor())
#       .progressr_analyse(condition = condition, dat = dat, fixed_objects = fixed_objects, ...)
#     },
#     summarise = summarise,
#     progress = FALSE
#   )
# })
#
progressify_SimDesign <- local({
  template_runSimulation_outer <- bquote_compile(local({
    design <- .(DESIGN)
    replications <- .(REPLICATIONS)
    .progressr_steps <- if (length(replications) == 1L) replications * nrow(design) else sum(replications)
    .progressr_progressor <- progressr::progressor(steps = .progressr_steps)
    .progressr_analyse <- .(ANALYSE)
    .(EXPR)
  }))

  template_runSimulation_FUN <- quote(function(condition, dat, fixed_objects = NULL, ...) {
    on.exit(.progressr_progressor())
    .progressr_analyse(condition = condition, dat = dat, fixed_objects = fixed_objects, ...)
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

    idx_design <- which(names == "design")
    idx_replications <- which(names == "replications")
    idx_analyse <- which(names == "analyse")

    parts <- as.list(expr)

    stopifnot(length(idx_design) == 1L)
    design <- parts[[idx_design]]
    parts[[idx_design]] <- quote(design)

    stopifnot(length(idx_replications) == 1L)
    replications <- parts[[idx_replications]]
    parts[[idx_replications]] <- quote(replications)

    stopifnot(length(idx_analyse) == 1L)
    analyse <- parts[[idx_analyse]]
    parts[[idx_analyse]] <- template_runSimulation_FUN

    # Inject progress = FALSE to disable SimDesign's native console progress bar
    idx_progress <- which(names == "progress")
    if (length(idx_progress) == 0L) {
      parts$progress <- FALSE
    }

    bquote_apply(template_runSimulation_outer,
                 DESIGN = design,
                 REPLICATIONS = replications,
                 ANALYSE = analyse,
                 EXPR = as.call(parts))
  } ## progressify_SimDesign()
})


append_builtin_transpilers_for_SimDesign <- local({
  known_fcns <- list(
    runSimulation = c
  )

  template <- bquote_compile(function(expr, options) {
    ns <- getNamespace("SimDesign")
    fcn <- get(.(fcn_name), mode = "function", envir = ns)
    progressify_SimDesign(expr, fcn_name = .(fcn_name), fcn = fcn, envir = parent.frame())
  })

  make_transpiler <- function(fcn_name) {
    transpiler <- eval(bquote_apply(template))
    eval(transpiler)
  }

  function() {
    ## SimDesign::runSimulation()
    transpilers <- list()
    for (fcn_name in names(known_fcns)) {
      transpilers[[fcn_name]] <- list(
        label = sprintf("SimDesign::%s() transpiler", fcn_name),
        transpiler = make_transpiler(fcn_name)
      )
    } ## for (fcn_name ...)
    transpilers <- list(SimDesign = transpilers)

    append_transpilers("progressify::built-in", transpilers)

    ## Return required packages
    c("SimDesign", "progressr")
  }
})
