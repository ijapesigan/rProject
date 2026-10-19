.VerifyLogScope <- function(lines,
                            level,
                            title,
                            subject) {
  # the "Files to update in Overleaf" headings of the push whose commit
  # message starts with `subject`; NULL (every list) when it is not found
  starts <- which(
    level > 0 & grepl(pattern = "Files to update in Overleaf", x = title)
  )
  subject <- trimws(c(subject, "")[1])
  fences <- which(grepl(pattern = "^```", x = lines))
  pairs <- seq_len(length(fences) %/% 2L)
  opens <- fences[2L * pairs - 1L]
  closes <- fences[2L * pairs]
  firsts <- vapply(
    X = seq_along(opens),
    FUN = function(i) {
      inside <- trimws(
        lines[opens[i] + seq_len(max(closes[i] - opens[i] - 1L, 0L))]
      )
      inside <- inside[nzchar(inside)]
      c(inside, "")[1]
    },
    FUN.VALUE = character(1)
  )
  found <- opens[nzchar(subject) & firsts == subject]
  # the newest block with that subject, and its level-2 section
  above <- which(level == 2L & seq_along(lines) < max(c(found, 0L)))
  if (length(found) == 0L || length(above) == 0L) {
    NULL
  } else if (grepl(pattern = "^Commit message", x = title[max(above)])) {
    # the change set of the log: its top-level lists
    starts[level[starts] == 2L]
  } else {
    # a later push in the log: the lists inside its section (none for a
    # push of records only)
    section <- max(above)
    after <- which(level > 0 & level <= 2L & seq_along(lines) > section)
    end <- c(after, length(lines) + 1L)[1]
    starts[starts > section & starts < end]
  }
}
