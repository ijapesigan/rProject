.UploadSubject <- function(lines,
                           fixup) {
  # the first line of the commit message block of the change set (the first
  # block) or of the newest fix-up (the first block after its heading)
  fences <- which(x = grepl(pattern = "^```", x = lines))
  pairs <- seq_len(length.out = length(x = fences) %/% 2L)
  opens <- fences[2L * pairs - 1L]
  if (fixup) {
    heading <- which(x = grepl(pattern = "^## Fix-up", x = lines))
    opens <- opens[opens > max(c(heading, 0L))]
    if (length(x = heading) == 0L) {
      opens <- integer(length = 0)
    }
  }
  subject <- NA_character_
  if (length(x = opens) > 0L) {
    inside <- trimws(
      x = lines[seq(from = opens[1] + 1L, to = length(x = lines))]
    )
    subject <- c(inside[nzchar(x = inside)], NA_character_)[1]
  }
  subject
}
