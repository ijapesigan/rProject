.LintTexScan <- function(path,
                         pattern,
                         rule,
                         message,
                         preamble = TRUE,
                         math = FALSE) {
  # the lines of LaTeX sources (math rules: roxygen and Markdown too) that
  # match a pattern; always a warning: prose has exceptions
  items <- lapply(
    X = .LintTexSources(path = path, preamble = preamble),
    FUN = function(file) {
      list(
        file = file,
        lines = .LintTexStrip(lines = .LintRead(path = path, file = file))
      )
    }
  )
  if (math) {
    items <- c(items, .LintMathSources(path = path))
  }
  .LintBind(
    rows = lapply(
      X = items,
      FUN = function(item) {
        hit <- grep(pattern = pattern, x = item$lines, perl = TRUE)
        .LintRow(
          file = rep(x = item$file, times = length(x = hit)),
          line = hit,
          rule = rule,
          message = message
        )
      }
    )
  )
}
