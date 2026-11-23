#' @tags pkg-tm
if (requireNamespace("tm", quietly = TRUE)) {

library(progressify)
library(tm)

options(progressify.debug = TRUE)

docs <- c(
  "The quick brown fox.",
  "Jumps over the lazy dog!",
  "Lorem ipsum dolor sit amet.",
  "Consectetur adipiscing elit, sed do eiusmod.",
  "Tempor incididunt ut labore et dolore magna aliqua."
)
ndocs <- length(docs)
vc <- VCorpus(VectorSource(docs))
sc <- Corpus(VectorSource(docs))
stopifnot(inherits(sc, "SimpleCorpus"))
has_fox <- function(x) any(grepl("fox", as.character(x)))

exprs <- list(
  tm_map = quote(tm_map(vc, content_transformer(tolower))),
  tm_map = quote(tm::tm_map(vc, removePunctuation)),
  TermDocumentMatrix = quote(TermDocumentMatrix(vc)),
  TermDocumentMatrix = quote(TermDocumentMatrix(vc, control = list(stopwords = TRUE))),
  DocumentTermMatrix = quote(DocumentTermMatrix(vc)),
  DocumentTermMatrix = quote(tm::DocumentTermMatrix(vc, control = list(removePunctuation = TRUE))),
  tm_index = quote(tm_index(vc, FUN = has_fox)),
  tm_index = quote(tm_index(sc, FUN = has_fox)),
  ## Dispatch argument is not a variable => method identified at run time
  TermDocumentMatrix = quote(TermDocumentMatrix(VCorpus(VectorSource(docs))))
)

## Compare corpora by their content, because their metadata include
## time stamps
as_comparable <- function(x) {
  if (inherits(x, "Corpus")) x <- lapply(x, FUN = as.character)
  x
}

for (kk in seq_along(exprs)) {
  name <- names(exprs)[kk]
  expr <- exprs[[kk]]
  message(sprintf("=== %s ==========================", name))
  print(expr)

  truth <- eval(expr)

  expr_f <- bquote(.(expr) |> progressify())
  print(expr_f)

  ## Count progress updates; progressr.enable = TRUE makes progressor()
  ## signal 'progression' conditions also in non-interactive mode
  engine_before <- tm_parLapply_engine()
  nupdates <- 0L
  oopts_progressr <- options(progressr.enable = TRUE)
  res <- withCallingHandlers(eval(expr_f), progression = function(p) {
    if (identical(p[["type"]], "update")) nupdates <<- nupdates + 1L
    invokeRestart("muffleProgression")
  })
  options(oopts_progressr)
  str(list(nupdates = nupdates))
  stopifnot(
    all.equal(as_comparable(res), as_comparable(truth)),
    nupdates == ndocs,
    identical(tm_parLapply_engine(), engine_before)
  )

  ## No output
  out <- utils::capture.output({
    res2 <- eval(expr_f)
  })
  stopifnot(
    length(out) == 0L,
    all.equal(as_comparable(res2), as_comparable(truth))
  )
}


## A user-specified engine is restored afterward
my_engine <- function(X, FUN, ...) lapply(X, FUN, ...)
tm_parLapply_engine(my_engine)
res <- TermDocumentMatrix(vc) |> progressify()
stopifnot(identical(tm_parLapply_engine(), my_engine))
tm_parLapply_engine(NULL)


## tm_map() for 'SimpleCorpus' objects does not use tm_parLapply()
res <- tryCatch(tm_map(sc, content_transformer(tolower)) |> progressify(), error = identity)
stopifnot(inherits(res, "error"))
message("Expected error: ", conditionMessage(res))

} # if (requireNamespace("tm", quietly = TRUE))
