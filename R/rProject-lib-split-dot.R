.LibSplit <- function(text) {
  # a .bib text split into its entries (one string each): an entry starts
  # at a line that begins with @type{; @comment, @string, and @preamble
  # are dropped
  lines <- unlist(x = strsplit(x = paste(text, collapse = "\n"), split = "\n"))
  starts <- grep(pattern = "^[[:space:]]*@[A-Za-z]+[[:space:]]*\\{", x = lines)
  if (length(x = starts) == 0L) {
    character(length = 0)
  } else {
    ends <- c(starts[-1] - 1L, length(x = lines))
    entries <- vapply(
      X = seq_along(along.with = starts),
      FUN = function(i) {
        paste(lines[starts[i]:ends[i]], collapse = "\n")
      },
      FUN.VALUE = character(length = 1)
    )
    entries[
      !grepl(
        pattern = "^[[:space:]]*@(comment|string|preamble)[[:space:]]*\\{",
        x = entries,
        ignore.case = TRUE
      )
    ]
  }
}
