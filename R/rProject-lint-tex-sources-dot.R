.LintTexSources <- function(path,
                            preamble = TRUE) {
  files <- .LintList(path = path, pattern = "^\\.setup/latex/.*\\.(Rtex|tex)$")
  files <- files[!grepl(pattern = "^\\.setup/latex/bib/", x = files)]
  if (!preamble) {
    files <- files[!grepl(pattern = "^\\.setup/latex/preamble/", x = files)]
  }
  files
}
