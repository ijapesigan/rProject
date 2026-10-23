.LibSplit <- function(text) {
  # a .bib text split into its entries (one string each): an entry starts
  # at a line that begins with @type{; @comment, @string, and @preamble
  # are dropped
  lines <- unlist(strsplit(x = paste(text, collapse = "\n"), split = "\n"))
  starts <- grep(pattern = "^[[:space:]]*@[A-Za-z]+[[:space:]]*\\{", x = lines)
  if (length(starts) == 0L) {
    character(0)
  } else {
    ends <- c(starts[-1] - 1L, length(lines))
    entries <- vapply(
      X = seq_along(starts),
      FUN = function(i) {
        paste(lines[starts[i]:ends[i]], collapse = "\n")
      },
      FUN.VALUE = character(1)
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
