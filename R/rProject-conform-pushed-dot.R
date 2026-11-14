.ConformPushed <- function(path,
                           log) {
  # a log is pushed when a row of the log index names it with a commit
  # (a pending row does not count)
  index <- file.path(path, ".setup", "logs", "index.md")
  if (file.exists(index)) {
    lines <- readLines(con = index, warn = FALSE)
    named <- grepl(
      pattern = paste0("| ", log, " |"),
      x = lines,
      fixed = TRUE
    )
    rows <- lines[named]
    any(!grepl(pattern = "(pending)", x = rows, fixed = TRUE))
  } else {
    FALSE
  }
}
