.LintTexBold <- function(path) {
  .LintTexScan(
    path = path,
    pattern = "\\\\(mathbf|bm)\\{",
    rule = "tex-bold",
    message = "use \\boldsymbol{}",
    preamble = FALSE,
    math = TRUE
  )
}
