.VerifyLogPending <- function(path) {
  index <- file.path(
    path,
    ".setup",
    "logs",
    "index.md"
  )
  rows <- character(0)
  if (file.exists(index)) {
    lines <- readLines(
      con = index,
      warn = FALSE
    )
    rows <- lines[grepl(pattern = "\\|\\s*\\(pending\\)\\s*\\|", x = lines)]
  }
  # newest first: the first pending row; NA when there is none
  cells <- trimws(strsplit(x = c(rows, "")[1], split = "|", fixed = TRUE)[[1]])
  c(cells[grepl(pattern = "\\.md$", x = cells)], NA_character_)[1]
}
