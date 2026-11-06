.LintShScript <- function(path) {
  # a shebang and strict mode (guide 007); a helper that is only sourced says
  # so in its header and sets nothing
  files <- .LintList(path = path, pattern = "\\.sh$")
  rows <- lapply(
    X = files,
    FUN = function(file) {
      lines <- readLines(con = file.path(path, file), warn = FALSE)
      if (length(x = lines) == 0L) {
        lines <- ""
      }
      header <- lines[seq_len(length.out = min(5L, length(x = lines)))]
      sourced <- any(
        grepl(pattern = "^#.*\\bsourced\\b", x = header, ignore.case = TRUE)
      )
      strict <- grepl(
        pattern = "^\\s*set\\s+-[A-Za-z]*e[A-Za-z]*u[A-Za-z]*o\\s+pipefail",
        x = lines
      )
      list(
        if (!startsWith(x = lines[1], prefix = "#!")) {
          .LintRow(
            file = file,
            line = 1L,
            rule = "sh-shebang",
            message = "start with #!/usr/bin/env bash"
          )
        },
        if (!sourced && !any(strict)) {
          .LintRow(
            file = file,
            line = 1L,
            rule = "sh-strict",
            message = "set -Eeuo pipefail before the first command"
          )
        }
      )
    }
  )
  .LintBind(rows = unlist(x = rows, recursive = FALSE))
}
