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
  if (length(rows) == 0L) {
    stop(
      paste0(
        "\n\nNo pending push in ",
        index,
        ". Pass `log`.\n\n"
      ),
      call. = FALSE
    )
  }
  # newest first: the first pending row
  cells <- trimws(strsplit(x = rows[1], split = "|", fixed = TRUE)[[1]])
  cells[grepl(pattern = "\\.md$", x = cells)][1]
}
