.LintHouse <- function(path,
                       type = NULL) {
  # every house check; the R checks share one parse of the R code
  code <- .LintRCode(path = path)
  needs_code <- c(
    ".LintRReturn", ".LintRNamespace", ".LintRNamedArgs", ".LintRBraces",
    ".LintRNolint"
  )
  rows <- lapply(
    X = .LintChecks(type = type),
    FUN = function(check) {
      lint_args <- list(path = path)
      if (check %in% needs_code) {
        lint_args$code <- code
      }
      if (check == ".LintTexCite") {
        lint_args$talk <- identical(x = type, y = "talk")
      }
      do.call(what = check, args = lint_args)
    }
  )
  rows <- .LintBind(rows = rows)
  rows[order(rows$file, rows$line, rows$rule), , drop = FALSE]
}
