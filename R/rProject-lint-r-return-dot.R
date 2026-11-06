.LintRReturn <- function(path,
                         code = .LintRCode(path = path)) {
  level <- .LintLevel(path = path)
  .LintBind(
    rows = lapply(
      X = code,
      FUN = function(item) {
        data <- item$data
        line <- integer(length = 0L)
        if (!is.null(x = data)) {
          line <- data$line1[
            data$token == "SYMBOL_FUNCTION_CALL" & data$text == "return"
          ]
        }
        .LintRow(
          file = rep(x = item$file, times = length(x = line)),
          line = line,
          rule = "no-return",
          message = "no return(): use if/else, skip_*(), or .CheckFoo()",
          level = level
        )
      }
    )
  )
}
