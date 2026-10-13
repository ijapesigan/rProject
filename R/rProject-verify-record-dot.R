.VerifyRecord <- function(path,
                          log,
                          sha,
                          result,
                          summary = "") {
  logs <- file.path(path, ".setup", "logs")
  pending <- "\\(pending\\)"
  date <- format(Sys.Date())
  # the log's "Pushes" table: | (pending) | | | -> | sha | date | result |
  # (a fix-up push without a pending row gets a new row)
  log_file <- file.path(logs, log)
  lines <- readLines(con = log_file, warn = FALSE)
  new_row <- paste0("| ", sha, " | ", date, " | ", result, " |")
  row <- which(grepl(pattern = paste0("^\\|\\s*", pending), x = lines))[1]
  if (!is.na(row)) {
    lines[row] <- new_row
  } else {
    lines <- .VerifyRecordInsert(
      lines = lines,
      heading = "## Pushes",
      row = new_row,
      last = TRUE
    )
  }
  writeLines(text = lines, con = log_file)
  # index.md: the pending row for this log, or a new row at the top
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
    } else {
      summary <- gsub(
        pattern = "|",
        replacement = "/",
        x = summary,
        fixed = TRUE
      )
      lines <- .VerifyRecordInsert(
        lines = lines,
        heading = NULL,
        row = paste(
          "|", date, "|", sha, "|", log, "|", summary, "|", result, "|"
        ),
        last = FALSE
      )
    }
    writeLines(text = lines, con = index)
  }
  invisible(NULL)
}
