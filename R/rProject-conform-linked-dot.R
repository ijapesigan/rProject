.ConformLinked <- function(file) {
  # files that Overleaf links (refresh the link, never upload): the
  # dependency copies and the bibliographies
  startsWith(x = file, prefix = ".setup/r-dependencies/") |
    file %in% c(
      ".setup/latex/bib/bib.bib",
      ".setup/quarto/bib/quarto.bib",
      "vignettes/vignettes.bib"
    )
}
