.LintRLocal <- function(path) {
  # the project's own functions and their formals, from R/ and test helpers
  files <- .LintList(
    path = path,
    pattern = "^(R/.*\\.[Rr]|tests/testthat/helper.*\\.[Rr])$"
  )
  found <- lapply(
    X = files,
    FUN = function(file) {
      exprs <- tryCatch(
        expr = parse(file = file.path(path, file), keep.source = FALSE),
        error = function(e) {
          expression()
        }
      )
      out <- list()
      for (expr in as.list(x = exprs)) {
        is_function <- is.call(x = expr) &&
          length(x = expr) == 3L &&
          as.character(x = expr[[1]])[1] %in% c("<-", "=") &&
          is.name(x = expr[[2]]) &&
          is.call(x = expr[[3]]) &&
          identical(x = expr[[3]][[1]], y = as.name(x = "function"))
        if (is_function) {
          out[[as.character(x = expr[[2]])]] <- names(x = expr[[3]][[2]])
        }
      }
      out
    }
  )
  do.call(what = c, args = found)
}
