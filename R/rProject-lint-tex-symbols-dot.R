.LintTexSymbols <- function(path) {
  .LintTexScan(
    path = path,
    pattern = paste0(
      "\\^T\\b|\\^\\{T\\}|\\^\\{?\\\\top\\b",
      "|\\\\boldsymbol\\{[^}]*\\}'",
      "|\\\\(text|mathrm)\\{(vec|vech|tr|diag|Cov|cov|Var|var)\\}",
      "|\\\\[A-Za-z]+\\{[^}]*\\}_[A-Za-z0-9]{2,}|\\$[A-Za-z]_[A-Za-z0-9]{2,}"
    ),
    rule = "tex-symbol",
    message = paste(
      "see the math guide: ^{\\prime}, \\operatorname{},",
      "braced subscripts"
    ),
    preamble = FALSE,
    math = TRUE
  )
}
