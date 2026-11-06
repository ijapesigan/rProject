.VerifyLogScope <- function(lines,
                            level,
                            title,
                            subject) {
  # the "Files to update in Overleaf" headings of the push whose commit
  # message starts with `subject`; NULL (every list) when it is not found
  starts <- which(
    x = level > 0 & grepl(pattern = "Files to update in Overleaf", x = title)
  )
  subject <- trimws(x = c(subject, "")[1])
  fences <- which(x = grepl(pattern = "^```", x = lines))
  pairs <- seq_len(length.out = length(x = fences) %/% 2L)
  opens <- fences[2L * pairs - 1L]
  closes <- fences[2L * pairs]
  firsts <- vapply(
    X = seq_along(along.with = opens),
    FUN = function(i) {
      inside <- trimws(
        x = lines[opens[i] + seq_len(
          length.out = max(closes[i] - opens[i] - 1L, 0L)
        )]
      )
      inside <- inside[nzchar(x = inside)]
      c(inside, "")[1]
    },
    FUN.VALUE = character(length = 1)
  )
  found <- opens[nzchar(x = subject) & firsts == subject]
  # the newest block with that subject, and its level-2 section
  above <- which(
    x = level == 2L & seq_along(along.with = lines) < max(c(found, 0L))
  )
  if (length(x = found) == 0L || length(x = above) == 0L) {
    NULL
  } else if (grepl(pattern = "^Commit message", x = title[max(above)])) {
    # the change set of the log: its top-level lists
    starts[level[starts] == 2L]
  } else {
    # a later push in the log: the lists inside its section (none for a
    # push of records only)
    section <- max(above)
    after <- which(
      x = level > 0 & level <= 2L & seq_along(along.with = lines) > section
    )
    end <- c(after, length(x = lines) + 1L)[1]
    starts[starts > section & starts < end]
  }
}
