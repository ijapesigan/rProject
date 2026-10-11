.LogIndex <- function(path,
                      log,
                      summary) {
  index <- file.path(path, ".setup", "logs", "index.md")
  header <- c(
    "# Log index",
    "",
    "Every Overleaf push, newest first.",
    "`Verify(record = TRUE)` fills in the commit and the result.",
    "",
    "| Date | Commit | Log | Summary | Verified |",
    "|---|---|---|---|---|"
  )
  lines <- header
  if (file.exists(index)) {
    lines <- readLines(
      con = index,
      warn = FALSE
    )
  }
  row <- paste0(
    "| ",
    substr(log, start = 1, stop = 10),
    " | (pending) | ",
    log,
    " | ",
    summary,
    " | |"
  )
  # newest first: right after the table's separator line
  separator <- which(grepl(pattern = "^\\|---", x = lines))[1]
  if (is.na(separator)) {
    lines <- c(lines, "", header[6:7], row)
  } else {
    lines <- append(
      x = lines,
      values = row,
      after = separator
    )
  }
  writeLines(
    text = lines,
    con = index
  )
  invisible(index)
}
