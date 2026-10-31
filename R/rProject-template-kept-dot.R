.TemplateKept <- function(files) {
  # template files kept in Overleaf as regular files (uploaded): the
  # files Overleaf needs to compile (tier 1), the Makefile (make needs it
  # to run at all), and the .gitignore files (a fresh clone keeps its
  # export rules), but not in .github/, which make writes whole
  files$tier == "1" | (
    basename(files$path) %in% c("Makefile", ".gitignore") &
      !startsWith(files$path, ".github/")
  )
}
