.SizeCheckDuplicates <- function(path,
                                 files) {
  out <- character(0)
  if (length(files) > 1L) {
    md5 <- unname(tools::md5sum(file.path(path, files)))
    groups <- split(x = files, f = md5)
    groups <- groups[lengths(groups) > 1L]
    out <- vapply(
      X = groups,
      FUN = function(group) {
        paste(group, collapse = " = ")
      },
      FUN.VALUE = character(1)
    )
  }
  unname(out)
}
