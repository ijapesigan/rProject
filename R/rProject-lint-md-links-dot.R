.LintMdLinks <- function(path) {
  .LintBind(
    rows = list(
      .LintMdScan(
        path = path,
        pattern = "(?<![<(\\[\"'=])\\bhttps?://",
        rule = "md-link",
        message = "put a bare URL in <...>, or use an inline link"
      ),
      .LintMdScan(
        path = path,
        pattern = "\\[(here|this|link)\\]\\(",
        rule = "md-link",
        message = "use descriptive link text",
        ignore_case = TRUE
      )
    )
  )
}
