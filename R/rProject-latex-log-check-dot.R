.LatexLogCheck <- function(logs) {
  # the documents whose last pdflatex run failed: latexmk -f keeps going and
  # leaves a stub PDF, so CI would report success
  fatal <- paste(
    c(
      "Fatal error occurred, no output PDF file produced",
      "TeX capacity exceeded",
      "Emergency stop"
    ),
    collapse = "|"
  )
  bad <- vapply(
    X = logs,
    FUN = function(log) {
      file.exists(log) && any(
        grepl(
          pattern = fatal,
          x = readLines(con = log, warn = FALSE)
        )
      )
    },
    FUN.VALUE = logical(1)
  )
  logs[bad]
}
