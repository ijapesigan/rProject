.LintBind <- function(rows) {
  rows <- rows[!vapply(
    X = rows,
    FUN = is.null,
    FUN.VALUE = logical(length = 1)
  )]
  if (length(x = rows) == 0L) {
    .LintRow(
      file = character(length = 0L),
      line = integer(length = 0L),
      rule = character(length = 0L),
      message = character(length = 0L)
    )
  } else {
    do.call(what = rbind, args = rows)
  }
}
