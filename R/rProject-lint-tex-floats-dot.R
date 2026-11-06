.LintTexFloats <- function(path) {
  floats <- "(figure|table|sidewaystable|sidewaysfigure)\\*?"
  .LintBind(
    rows = lapply(
      X = .LintTexSources(path = path, preamble = FALSE),
      FUN = function(file) {
        lines <- .LintTexStrip(lines = .LintRead(path = path, file = file))
        opens <- grep(
          pattern = paste0("\\\\begin\\{", floats, "\\}"),
          x = lines
        )
        closes <- grep(pattern = paste0("\\\\end\\{", floats, "\\}"), x = lines)
        bad <- integer(length = 0L)
        for (open in opens) {
          close <- closes[closes >= open][1]
          if (!is.na(x = close)) {
            body <- paste(lines[seq(from = open, to = close)], collapse = " ")
            if (
              !grepl(pattern = "\\caption", x = body, fixed = TRUE) ||
                !grepl(pattern = "\\label", x = body, fixed = TRUE)
            ) {
              bad <- c(bad, open)
            }
          }
        }
        .LintRow(
          file = rep(x = file, times = length(x = bad)),
          line = bad,
          rule = "tex-float",
          message = "a float needs \\caption and \\label"
        )
      }
    )
  )
}
