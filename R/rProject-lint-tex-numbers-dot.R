.LintTexNumbers <- function(path) {
  .LintTexScan(
    path = path,
    pattern = "\\b(Equation|Table|Figure|Section)s?[ ~][0-9]",
    rule = "tex-number",
    message = "do not type the number: use \\ref",
    preamble = FALSE
  )
}
