.LintRNamedArgs <- function(path,
                            code = .LintRCode(path = path)) {
  level <- .LintLevel(path = path)
  known <- .LintRKnown(path = path)
  exempt <- c("return", "function")
  .LintBind(
    rows = lapply(
      X = code,
      FUN = function(item) {
        own <- character(length = 0L)
        if (!is.null(x = item$data)) {
          own <- .LintROwn(data = item$data)
        }
        calls <- .LintRCalls(data = item$data)
        calls <- calls[!vapply(
          X = calls,
          FUN = is.null,
          FUN.VALUE = logical(length = 1)
        )]
        rows <- lapply(
          X = calls,
          FUN = function(call) {
            if (call$name %in% exempt || (
              is.na(x = call$pkg) && call$name %in% own
            )) {
              NULL
            } else {
              missed <- .LintRPositional(
                call = call,
                fml = .LintRFormals(
                  name = call$name,
                  pkg = call$pkg,
                  known = known
                )
              )
              if (length(x = missed) == 0L) {
                NULL
              } else {
                .LintRow(
                  file = rep(x = item$file, times = length(x = missed)),
                  line = vapply(
                    X = missed,
                    FUN = `[[`,
                    FUN.VALUE = integer(length = 1),
                    "line"
                  ),
                  rule = "named-args",
                  message = vapply(
                    X = missed,
                    FUN = function(arg) {
                      paste0(
                        call$name, "(): name the argument `", arg$formal, " = `"
                      )
                    },
                    FUN.VALUE = character(length = 1)
                  ),
                  level = level
                )
              }
            }
          }
        )
        .LintBind(rows = rows)
      }
    )
  )
}
