.TemplateHas <- function(files,
                         keys) {
  # which files hold any of the {{key}} placeholders
  pattern <- paste0("\\{\\{(", paste(keys, collapse = "|"), ")\\}\\}")
  vapply(
    X = files,
    FUN = function(x) {
      any(grepl(pattern = pattern, x = readLines(con = x, warn = FALSE)))
    },
    FUN.VALUE = logical(1),
    USE.NAMES = FALSE
  )
}
