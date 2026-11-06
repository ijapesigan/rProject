.LintMdScan <- function(path,
                        pattern,
                        rule,
                        message,
                        ignore_case = FALSE) {
  .LintBind(
    rows = lapply(
      X = .LintMdList(path = path),
      FUN = function(file) {
        hit <- grep(
          pattern = pattern,
          x = .LintMdStrip(lines = .LintRead(path = path, file = file)),
          perl = TRUE,
          ignore.case = ignore_case
        )
        .LintRow(
          file = rep(x = file, times = length(x = hit)),
          line = hit,
          rule = rule,
          message = message
        )
      }
    )
  )
}
