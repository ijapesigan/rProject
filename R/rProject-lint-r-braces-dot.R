.LintRBraces <- function(path,
                         code = .LintRCode(path = path)) {
  level <- .LintLevel(path = path)
  .LintBind(
    rows = lapply(
      X = code,
      FUN = function(item) {
        lines <- .LintRBracesLines(data = item$data)
        if (length(x = lines) == 0L) {
          NULL
        } else {
          .LintRow(
            file = rep(x = item$file, times = length(x = lines)),
            line = lines,
            rule = "braces",
            message = "put the body in {}",
            level = level
          )
        }
      }
    )
  )
}
