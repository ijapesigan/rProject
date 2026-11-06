.LintCppFormat <- function(path) {
  # clang-format's verdict; nothing to report when it is not installed
  level <- .LintLevel(path = path)
  files <- .LintCppList(path = path)
  if (Sys.which(names = "clang-format") == "" || length(x = files) == 0L) {
    .LintBind(rows = list())
  } else {
    .LintBind(
      rows = lapply(
        X = files,
        FUN = function(file) {
          status <- suppressWarnings(
            expr = system2(
              command = "clang-format",
              args = c(
                .LintCppStyle(),
                "--dry-run",
                "--Werror",
                .ShellQuote(x = file.path(path, file))
              ),
              stdout = FALSE,
              stderr = FALSE
            )
          )
          if (status == 0L) {
            NULL
          } else {
            .LintRow(
              file = file,
              line = 1L,
              rule = "cpp-format",
              message = "run make style (clang-format)",
              level = level
            )
          }
        }
      )
    )
  }
}
