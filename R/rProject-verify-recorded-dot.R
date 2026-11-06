.VerifyRecorded <- function(path,
                            sha) {
  index <- file.path(path, ".setup", "logs", "index.md")
  recorded <- FALSE
  if (file.exists(index) && length(x = sha) == 1L && nzchar(x = sha)) {
    lines <- readLines(
      con = index,
      warn = FALSE
    )
    commits <- vapply(
      X = strsplit(x = lines, split = "|", fixed = TRUE),
      FUN = function(cells) {
        trimws(x = c(cells, "", "")[3])
      },
      FUN.VALUE = character(length = 1)
    )
    recorded <- sha %in% commits
  }
  recorded
}
