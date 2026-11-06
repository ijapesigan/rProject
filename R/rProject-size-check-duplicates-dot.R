.SizeCheckDuplicates <- function(path,
                                 files) {
  out <- character(length = 0)
  if (length(x = files) > 1L) {
    md5 <- unname(obj = tools::md5sum(files = file.path(path, files)))
    groups <- split(x = files, f = md5)
    groups <- groups[lengths(x = groups) > 1L]
    out <- vapply(
      X = groups,
      FUN = function(group) {
        paste(group, collapse = " = ")
      },
      FUN.VALUE = character(length = 1)
    )
  }
  unname(obj = out)
}
