.LintTexStrip <- function(lines) {
  # blank comments (knitr chunks are comments too) and verbatim blocks;
  # line numbers hold
  inside <- FALSE
  for (i in seq_along(along.with = lines)) {
    opens <- grepl(
      pattern = "\\\\begin\\{(Verbatim|verbatim|lstlisting)\\}",
      x = lines[i]
    )
    closes <- grepl(
      pattern = "\\\\end\\{(Verbatim|verbatim|lstlisting)\\}",
      x = lines[i]
    )
    if (opens) {
      inside <- TRUE
    }
    if (inside) {
      lines[i] <- ""
    }
    if (closes) {
      inside <- FALSE
    }
  }
  sub(pattern = "(?<!\\\\)%.*$", replacement = "", x = lines, perl = TRUE)
}
