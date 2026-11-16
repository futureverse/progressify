# Sim.DiffProc::MCM.sde(model, statistic, R = 100, ...) =>
#
# local({
#   .progressr_steps <- R
#   .progressr_progressor <- progressr::progressor(steps = .progressr_steps)
#   .progressr_model <- model
#   ## MCM.sde() simulates the R batches by evaluating 'model$call',
#   ## which we prepend with a progress update
#   .progressr_model_call <- .progressr_model[["call"]]
#   .progressr_model[["call"]] <- call("{",
#     as.call(list(.progressr_progressor)),
#     .progressr_model_call
#   )
#   .progressr_res <- Sim.DiffProc::MCM.sde(
#     model = .progressr_model,
#     statistic = statistic,
#     R = .progressr_steps,
#     ...
#   )
#   ## Undo the above change of the model returned
#   if (inherits(.progressr_res, "MCM.sde")) {
#     .progressr_res[["mod"]][["call"]] <- .progressr_model_call
#   }
#   .progressr_res
# })
#
# Note that 'statistic' is only called after all R batches have been
# simulated. Since it is fast relative to the simulations, it is not
# used for progress updates.
#
progressify_Sim.DiffProc <- local({
  template_MCM.sde_outer <- bquote_compile(local({
    .progressr_steps <- .(STEPS)
    .progressr_progressor <- progressr::progressor(steps = .progressr_steps)
    .progressr_model <- .(MODEL)
    .progressr_model_call <- .progressr_model[["call"]]
    .progressr_model[["call"]] <- call("{",
      as.call(list(.progressr_progressor)),
      .progressr_model_call
    )
    .progressr_res <- .(EXPR)
    if (inherits(.progressr_res, "MCM.sde")) {
      .progressr_res[["mod"]][["call"]] <- .progressr_model_call
    }
    .progressr_res
  }))

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

    parts <- as.list(expr)
    names(parts) <- names

    idx_model <- which(names == "model")
    stopifnot(length(idx_model) == 1L)
    model <- parts[[idx_model]]
    parts[[idx_model]] <- quote(.progressr_model)

    idx_R <- which(names == "R")
    if (length(idx_R) == 1L) {
      steps <- parts[[idx_R]]
    } else {
      steps <- formals(fcn)[["R"]]
    }
    parts[["R"]] <- quote(.progressr_steps)

    bquote_apply(template_MCM.sde_outer, STEPS = steps, MODEL = model, EXPR = as.call(parts))
  } ## progressify_Sim.DiffProc()
})


append_builtin_transpilers_for_Sim.DiffProc <- local({
  ## MCM.sde() is an S3 generic function, but there is only a default
  ## method, which is the one used to match arguments
  known_fcns <- list(
    MCM.sde = c
  )

  template <- bquote_compile(function(expr, options) {
    ns <- getNamespace("Sim.DiffProc")
    fcn <- get(paste0(.(fcn_name), ".default"), mode = "function", envir = ns)
    progressify_Sim.DiffProc(expr, fcn_name = .(fcn_name), fcn = fcn, envir = parent.frame())
  })

  make_transpiler <- function(fcn_name) {
    transpiler <- eval(bquote_apply(template))
    eval(transpiler)
  }

  function() {
    ## Sim.DiffProc::MCM.sde()
    transpilers <- list()
    for (fcn_name in names(known_fcns)) {
      transpilers[[fcn_name]] <- list(
        label = sprintf("Sim.DiffProc::%s() transpiler", fcn_name),
        transpiler = make_transpiler(fcn_name)
      )
    } ## for (fcn_name ...)
    transpilers <- list(Sim.DiffProc = transpilers)

    append_transpilers("progressify::built-in", transpilers)

    ## Return required packages
    c("Sim.DiffProc", "progressr")
  }
})
