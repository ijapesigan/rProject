.LintCiPin <- function(path) {
  # an action at a release tag, never a moving branch (guide 007)
  files <- .LintList(path = path, pattern = "^\\.github/workflows/.*\\.ya?ml$")
  rows <- lapply(
    X = files,
    FUN = function(file) {
      lines <- readLines(con = file.path(path, file), warn = FALSE)
      hit <- which(
        x = grepl(
          pattern = "\\buses:\\s*\\S+@(main|master|develop|dev|latest)\\b",
          x = lines
        )
      )
      .LintRow(
        file = rep_len(x = file, length.out = length(x = hit)),
        line = hit,
        rule = "ci-pin",
        message = "use a release tag, not a moving branch"
      )
    }
  )
  .LintBind(rows = rows)
}
