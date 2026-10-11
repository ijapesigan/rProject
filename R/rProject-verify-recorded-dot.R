.VerifyRecorded <- function(path,
                            sha) {
  index <- file.path(path, ".setup", "logs", "index.md")
  recorded <- FALSE
  if (file.exists(index) && length(sha) == 1L && nzchar(sha)) {
    lines <- readLines(
      con = index,
      warn = FALSE
    )
    commits <- vapply(
      X = strsplit(x = lines, split = "|", fixed = TRUE),
      FUN = function(cells) {
        trimws(c(cells, "", "")[3])
      },
      FUN.VALUE = character(1)
    )
    recorded <- sha %in% commits
  }
  recorded
}
