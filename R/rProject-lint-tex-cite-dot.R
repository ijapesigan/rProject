.LintTexCite <- function(path,
                         talk = FALSE) {
  # talks may use any biblatex-apa command; natbib is never right
  natbib <- "citep|citet|citealp|citealt|citeauthor|citeyear|citeyearpar"
  biblatex <- "cite|Cite|autocite|footcite|fullcite"
  commands <- ifelse(
    test = talk,
    yes = natbib,
    no = paste0(natbib, "|", biblatex)
  )
  .LintTexScan(
    path = path,
    pattern = paste0("\\\\(", commands, ")\\*?(\\[|\\{)"),
    rule = "tex-cite",
    message = "use \\parencite or \\textcite"
  )
}
