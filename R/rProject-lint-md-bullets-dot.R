.LintMdBullets <- function(path) {
  .LintMdScan(
    path = path,
    pattern = "^\\s*[*+]\\s+\\S",
    rule = "md-bullet",
    message = "use - for bullets"
  )
}
