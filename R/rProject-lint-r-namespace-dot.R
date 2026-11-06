.LintRNamespace <- function(path,
                            code = .LintRCode(path = path)) {
  level <- .LintLevel(path = path)
  known <- .LintRKnown(path = path)
  .LintBind(
    rows = lapply(
      X = code,
      FUN = function(item) {
        data <- item$data
        if (is.null(x = data)) {
          NULL
        } else {
          # a function the file defines, or an argument, is not the package's
          own <- c(.LintROwn(data = data), names(x = known$local))
          calls <- .LintRCalls(data = data)
          calls <- calls[!vapply(
            X = calls,
            FUN = is.null,
            FUN.VALUE = logical(length = 1)
          )]
          hits <- Filter(
            f = function(call) {
              is.na(x = call$pkg) &&
                call$name %in% names(x = known$pkg) &&
                !(call$name %in% known$base) &&
                !(call$name %in% own)
            },
            x = calls
          )
          if (length(x = hits) == 0L) {
            NULL
          } else {
            .LintRow(
              file = rep(x = item$file, times = length(x = hits)),
              line = vapply(
                X = hits,
                FUN = `[[`,
                FUN.VALUE = integer(length = 1),
                "line"
              ),
              rule = "namespace",
              message = vapply(
                X = hits,
                FUN = function(call) {
                  paste0("use ", known$pkg[[call$name]], "::", call$name, "()")
                },
                FUN.VALUE = character(length = 1)
              ),
              level = level
            )
          }
        }
      }
    )
  )
}
