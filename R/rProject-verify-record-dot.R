.VerifyRecord <- function(path,
                          log,
                          sha,
                          result) {
  logs <- file.path(path, ".setup", "logs")
  pending <- "\\(pending\\)"
  # the log's "Pushes" table: | (pending) | | | -> | sha | date | result |
  log_file <- file.path(logs, log)
  lines <- readLines(con = log_file, warn = FALSE)
  row <- which(grepl(pattern = paste0("^\\|\\s*", pending), x = lines))[1]
  if (!is.na(row)) {
    lines[row] <- paste0(
      "| ",
      sha,
      " | ",
      format(Sys.Date()),
      " | ",
      result,
      " |"
    )
    writeLines(text = lines, con = log_file)
  }
  # index.md: the pending row for this log
  index <- file.path(logs, "index.md")
  if (file.exists(index)) {
    lines <- readLines(con = index, warn = FALSE)
    row <- which(
      grepl(pattern = pending, x = lines) &
        grepl(pattern = log, x = lines, fixed = TRUE)
    )[1]
    if (!is.na(row)) {
      lines[row] <- sub(pattern = pending, replacement = sha, x = lines[row])
      lines[row] <- sub(
        pattern = "\\|\\s*\\|\\s*$",
        replacement = paste0("| ", result, " |"),
        x = lines[row]
      )
      writeLines(text = lines, con = index)
    }
  }
  invisible(NULL)
}
