.VerifyRecordSection <- function(lines,
                                 heading) {
  # the first table after `heading`: the header line and the data rows
  # (the template's header when the section or the table is missing)
  default <- "| Commit | Date | Result |"
  start <- which(x = lines == heading)[1]
  out <- list(header = default, rows = integer(length = 0))
  if (!is.na(x = start)) {
    separator <- which(
      x = grepl(pattern = "^\\|(\\s*:?-+:?\\s*\\|)+\\s*$", x = lines) &
        seq_along(along.with = lines) > start
    )[1]
    if (!is.na(x = separator) && separator > 1L) {
      at <- separator
      while (
        at < length(x = lines) && grepl(pattern = "^\\|", x = lines[at + 1L])
      ) {
        at <- at + 1L
      }
      out$header <- lines[separator - 1L]
      out$rows <- seq_len(length.out = at)[seq_len(length.out = at) > separator]
    }
  }
  out
}
