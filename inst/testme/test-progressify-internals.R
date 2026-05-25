library(progressify)
options(progressify.debug = TRUE)

message("*** Internals")

# --------------------------------------------------------------------
# Debug functions
# --------------------------------------------------------------------
message("debug_indent()")
oopts <- options(warn = 2L)
res <- tryCatch(progressify:::debug_indent(delta = -1L), error = identity)
print(res)
stopifnot(inherits(res, "error"))
options(oopts)


# --------------------------------------------------------------------
# .onLoad()
# --------------------------------------------------------------------
message(".onLoad()")
progressify:::.onLoad("progressify", "progressify")


# --------------------------------------------------------------------
# bquote_compile() and bquote_apply()
# --------------------------------------------------------------------
message("bquote_compile() and bquote_apply()")
bquote_compile <- progressify:::bquote_compile
bquote_apply <- progressify:::bquote_apply

tmpl <- bquote_compile(function(a = .(X), b = .(Y)) { a + b })
expr <- bquote_apply(tmpl, X = 42, Y = NULL)
f <- formals(eval(expr))
stopifnot(identical(f$a, 42))
stopifnot(is.null(f$b))


# --------------------------------------------------------------------
# import_progressr() and import_from()
# --------------------------------------------------------------------
message("import_progressr() and import_from()")
import_from <- progressify:::import_from
import_progressr <- progressify:::import_progressr

fcn <- import_progressr("progressor")
stopifnot(is.function(fcn))

fcn <- import_progressr("nonExistingFcn", default = identity)
stopifnot(identical(fcn, identity))

res <- tryCatch(
  import_progressr("nonExistingFcn"),
  error = identity
)
stopifnot(inherits(res, "error"))

fcn <- import_from("lapply", package = "base")
stopifnot(identical(fcn, base::lapply))

fcn <- import_from("nonExisting", package = "base", default = sum)
stopifnot(identical(fcn, sum))

res <- tryCatch(
  import_from("nonExisting", package = "base"),
  error = identity
)
stopifnot(inherits(res, "error"))


# --------------------------------------------------------------------
# S3 dispatching
# --------------------------------------------------------------------
message("S3 dispatch")
is_s3_generic <- progressify:::is_s3_generic
find_s3_method <- progressify:::find_s3_method

my_generic <- function(x) UseMethod("my_generic")
stopifnot(is_s3_generic(my_generic))
stopifnot(!is_s3_generic(lapply))
stopifnot(!is_s3_generic(sum))
stopifnot(!is_s3_generic(function() NULL))

my_generic.default <- function(x) "default"
my_generic.my_class <- function(x) "my_class"

obj <- structure(list(), class = "my_class")
res <- find_s3_method(my_generic, "my_generic", quote(my_generic(obj)), envir = environment())
stopifnot(identical(res$name, "my_generic.my_class"))

fempty <- function() {}
res_empty <- find_s3_method(fempty, "fempty", quote(fempty()), envir = environment())
stopifnot(is.null(res_empty))

fdots <- function(...) {}
res_dots <- find_s3_method(fdots, "fdots", quote(fdots()), envir = environment())
stopifnot(is.null(res_dots))

res_unmatched <- find_s3_method(my_generic, "my_generic", quote(my_generic(a, b, c)), envir = environment())
stopifnot(is.null(res_unmatched))

res_lit <- find_s3_method(my_generic, "my_generic", quote(my_generic(1)), envir = environment())
stopifnot(is.null(res_lit))

res_null <- find_s3_method(my_generic, "my_generic", quote(my_generic(nonexistent_obj)), envir = environment())
stopifnot(is.null(res_null))


# --------------------------------------------------------------------
# S4 dispatching
# --------------------------------------------------------------------
message("S4 dispatch")
find_s4_method <- progressify:::find_s4_method

methods::setClass("MyS4Class", slots = list(name = "character"))
methods::setGeneric("my_s4_generic", function(x) standardGeneric("my_s4_generic"))
methods::setMethod("my_s4_generic", signature = "MyS4Class", function(x) "s4_method")

obj <- methods::new("MyS4Class", name = "test")
res <- find_s4_method(my_s4_generic, "my_s4_generic", quote(my_s4_generic(obj)), envir = environment())
stopifnot(identical(res$name, "my_s4_generic"))

res_nons4 <- find_s4_method(identity, "identity", quote(identity(1)), envir = environment())
stopifnot(is.null(res_nons4))


# --------------------------------------------------------------------
# Transpiler registry
# --------------------------------------------------------------------
message("Transpiler registry")
transpilers_for_package <- progressify:::transpilers_for_package
transpiler_packages <- progressify:::transpiler_packages
list_transpilers <- progressify:::list_transpilers

transpilers_for_package(type = "test-type", package = "test-pkg", action = "reset")
transpilers_for_package(type = "test-type", package = "test-pkg", fcn = function() "test-pkg", action = "add")

res_get <- transpilers_for_package(type = "test-type", package = "test-pkg", action = "get")
stopifnot(length(res_get) == 1L)

res_list <- transpilers_for_package(type = "test-type", action = "list")
stopifnot(length(res_list) >= 1L)

res_make <- transpilers_for_package(type = "test-type", package = "test-pkg", action = "make")
stopifnot(identical(res_make, "test-pkg"))

df_pkgs <- transpiler_packages(classes = "test-type")
stopifnot(is.data.frame(df_pkgs))

df_list <- list_transpilers(class = "progressify::built-in")
stopifnot(is.data.frame(df_list))

df_filtered <- list_transpilers(pattern = "^ba", class = "progressify::built-in")
stopifnot(is.data.frame(df_filtered))


# --------------------------------------------------------------------
# parse_call() and transpile() edge cases
# --------------------------------------------------------------------
message("parse_call and transpile edge cases")
parse_call <- progressify:::parse_call
transpile <- progressify:::transpile

res <- tryCatch({
  parse_call(quote(1))
}, error = function(e) e)
stopifnot(inherits(res, "error"))

append_call_arguments <- progressify:::append_call_arguments
res_appended <- append_call_arguments(quote(my_fcn(x)), y = 2)
stopifnot(identical(res_appended, quote(my_fcn(x, y = 2))))

register_all_transpilers <- progressify:::register_all_transpilers
register_all_transpilers()
