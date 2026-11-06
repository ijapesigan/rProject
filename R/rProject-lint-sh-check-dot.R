.LintShCheck <- function(path) {
  # shellcheck, when the image has it (guide 007); CI runs it either way
  shellcheck <- Sys.which(names = "shellcheck")
  files <- .LintList(path = path, pattern = "\\.sh$")
  if (!nzchar(x = shellcheck) || length(x = files) == 0L) {
    .LintBind(rows = list())
  } else {
    out <- suppressWarnings(
      expr = system2(
        command = shellcheck,
        args = c("--format=gcc", shQuote(string = file.path(path, files))),
        stdout = TRUE,
        stderr = FALSE
      )
    )
    # each finding has its file, line, column, level, and message
    pattern <- "^(.*):([0-9]+):[0-9]+: [a-z]+: (.*)$"
    out <- out[grepl(pattern = pattern, x = out)]
    file <- sub(pattern = pattern, replacement = "\\1", x = out)
    .LintBind(
      rows = list(
        .LintRow(
          file = sub(
            pattern = paste0(path, "/"),
            replacement = "",
            x = file,
            fixed = TRUE
          ),
          line = as.integer(
            x = sub(pattern = pattern, replacement = "\\2", x = out)
          ),
          rule = "sh-check",
          message = sub(pattern = pattern, replacement = "\\3", x = out)
        )
      )
    )
  }
}
