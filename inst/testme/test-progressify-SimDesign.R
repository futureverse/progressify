#' @tags pkg-SimDesign
if (requireNamespace("SimDesign", quietly = TRUE)) {
  library(progressify)
  library(SimDesign)

  options(progressify.debug = TRUE)

  # Create small design
  Design <- createDesign(factor1 = c(1, 2))

  Generate <- function(condition, fixed_objects = NULL) {
    rnorm(100)
  }

  Analyse <- function(condition, dat, fixed_objects = NULL) {
    mean(dat)
  }

  Summarise <- function(condition, results, fixed_objects = NULL) {
    mean(results)
  }

  exprs <- list(
    runSimulation = quote(runSimulation(design = Design, replications = 5L,
                                        generate = Generate, analyse = Analyse,
                                        summarise = Summarise, verbose = FALSE))
  )

  # Helper to strip all custom metadata attributes and runtime-varying columns
  strip_attributes <- function(df) {
    df <- as.data.frame(df)
    # Remove metadata columns that differ on each run
    for (col in c("SIM_TIME", "RAM_USED", "COMPLETED", "SEED")) {
      df[[col]] <- NULL
    }
    attributes(df) <- list(
      names = names(df),
      row.names = seq_len(nrow(df)),
      class = "data.frame"
    )
    df
  }

  for (name in names(exprs)) {
    message(sprintf("Testing %s ...", name))
    expr <- exprs[[name]]

    # Ensure reproducible seed
    set.seed(42)
    truth <- eval(expr)

    set.seed(42)
    res <- eval(bquote(.(expr) |> progressify()))

    # Ensure results are equivalent
    stopifnot(all.equal(strip_attributes(res), strip_attributes(truth)))

    # Ensure no stdout leakage
    output <- utils::capture.output({
      set.seed(42)
      res2 <- eval(bquote(.(expr) |> progressify()))
    })
    stopifnot(length(output) == 0L)

    # Ensure repeated evaluation is identical
    stopifnot(all.equal(strip_attributes(res2), strip_attributes(res)))

    message(sprintf("Testing %s ... done", name))
  }
}
