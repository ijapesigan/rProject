.VerifyRecordInsert <- function(lines,
                                heading,
                                row,
                                last) {
  # the first table after `heading` (or the first table when NULL)
  start <- 1L
  if (!is.null(heading)) {
    start <- c(which(lines == heading), length(lines) + 1L)[1]
  }
  separator <- which(
    grepl(pattern = "^\\|(\\s*-+\\s*\\|)+\\s*$", x = lines) &
      seq_along(lines) > start
  )[1]
  if (is.na(separator)) {
    lines <- c(lines, "", row)
  } else {
    at <- separator
    if (last) {
      # after the last row of the table
      while (
        at < length(lines) && grepl(pattern = "^\\|", x = lines[at + 1L])
      ) {
        at <- at + 1L
      }
    }
    lines <- append(x = lines, values = row, after = at)
  }
  lines
}
