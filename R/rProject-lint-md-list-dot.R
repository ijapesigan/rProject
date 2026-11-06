.LintMdList <- function(path) {
  # Markdown sources; not generated files
  files <- .LintList(path = path, pattern = "\\.(md|Rmd|qmd)$|\\.Rmd\\.orig$")
  generated <- c("README.md", "LICENSE.md", "CLAUDE.md")
  files <- files[!(files %in% generated)]
  files <- files[!grepl(pattern = "^\\.setup/repo/", x = files)]
  built <- file.path(
    "vignettes",
    sub(
      pattern = "\\.orig$",
      replacement = "",
      x = basename(
        path = files[grepl(pattern = "^\\.setup/vignettes/", x = files)]
      )
    )
  )
  files[!(files %in% built)]
}
