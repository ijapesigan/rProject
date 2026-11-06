.LintTexTilde <- function(path) {
  .LintTexScan(
    path = path,
    pattern = paste0(
      "\\b(Equation|Table|Figure|Section|Stage|Step)s? +",
      "(\\\\ref|\\\\eqref|[0-9])"
    ),
    rule = "tex-tilde",
    message = "use a non-breaking space (~) before the reference or number",
    preamble = FALSE
  )
}
