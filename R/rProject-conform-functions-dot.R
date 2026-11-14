.ConformFunctions <- function(file) {
  # the top-level functions of an R file: their names, and whether one of
  # them is an S3 generic (UseMethod)
  exprs <- tryCatch(
    expr = as.list(x = parse(file = file, keep.source = FALSE)),
    error = function(e) {
      list()
    }
  )
  is_function <- vapply(
    X = exprs,
    FUN = function(e) {
      is.call(x = e) &&
        identical(x = e[[1]], y = as.name(x = "<-")) &&
        is.name(x = e[[2]]) &&
        is.call(x = e[[3]]) &&
        identical(x = e[[3]][[1]], y = as.name(x = "function"))
    },
    FUN.VALUE = logical(length = 1)
  )
  exprs <- exprs[is_function]
  list(
    names = vapply(
      X = exprs,
      FUN = function(e) {
        as.character(x = e[[2]])
      },
      FUN.VALUE = character(length = 1)
    ),
    s3 = any(
      vapply(
        X = exprs,
        FUN = function(e) {
          any(grepl(pattern = "UseMethod", x = deparse(expr = e)))
        },
        FUN.VALUE = logical(length = 1)
      )
    )
  )
}
