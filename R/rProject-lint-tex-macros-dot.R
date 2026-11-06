.LintTexMacros <- function(path) {
  .LintTexScan(
    path = path,
    pattern = paste0(
      "\\\\(newcommand|renewcommand|providecommand|DeclareMathOperator)",
      "\\b"
    ),
    rule = "tex-macro",
    message = "no macros outside .setup/latex/preamble/",
    preamble = FALSE
  )
}
