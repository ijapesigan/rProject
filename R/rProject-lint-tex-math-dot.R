.LintTexMath <- function(path) {
  .LintTexScan(
    path = path,
    pattern = paste0(
      "\\\\(Alpha|Beta|Epsilon|Zeta|Eta|Iota|Kappa|Mu|Nu|Omicron|Rho|Tau|Chi",
      "|argmax|argmin)(?![A-Za-z])"
    ),
    rule = "tex-math",
    message = "not portable: see the math guide (\\mathrm{B}, \\operatorname*)",
    preamble = FALSE,
    math = TRUE
  )
}
