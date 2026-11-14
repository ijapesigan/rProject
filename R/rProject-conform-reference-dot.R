.ConformReference <- function(path,
                              reference,
                              skip) {
  # the file set of the project against the reference: generated,
  # linked, and project-specific folders are left out; the project's own
  # name is `{pkg}` in both
  if (is.null(x = reference)) {
    .ConformEmpty()
  } else {
    set <- function(root) {
      pkg <- .LintPkg(path = root)
      files <- .LintList(path = root, pattern = ".")
      files <- sub(
        pattern = "/gitignore$",
        replacement = "/.gitignore",
        x = files
      )
      prefixes <- c(
        "R/", "tests/testthat/test-", "tests/testthat/helper-", "src/",
        ".setup/cpp/", ".setup/r-dependencies/", ".setup/tests-",
        ".setup/data-", ".setup/r-miscellaneous/", ".setup/bin/", ".sim/",
        ".github/", ".setup/scripts/", ".setup/latex/pdf/",
        ".setup/latex/figures/", "inst/", ".setup/ai/", ".setup/logs/", "data/"
      )
      generated <- c(
        "README.md", "CITATION.cff", "LICENSE", "LICENSE.md", "NAMESPACE",
        ".Rbuildignore", "project.Rproj", "AGENTS.md", "CLAUDE.md",
        "Makefile", ".Renviron", ".Rprofile", ".setup/latex/bib/bib.bib",
        ".setup/quarto/bib/quarto.bib", "vignettes/vignettes.bib"
      )
      drop <- vapply(
        X = files,
        FUN = function(i) {
          any(startsWith(x = i, prefix = prefixes)) ||
            i %in% c(generated, skip) ||
            grepl(pattern = "\\.log$", x = i)
        },
        FUN.VALUE = logical(length = 1),
        USE.NAMES = FALSE
      )
      gsub(
        pattern = pkg,
        replacement = "{pkg}",
        x = files[!drop],
        fixed = TRUE
      )
    }
    here <- set(root = path)
    there <- set(root = reference)
    pkg <- .LintPkg(path = path)
    .ConformBind(
      rows = list(
        .ConformRow(
          rule = "file-set-missing",
          class = "decide",
          file = gsub(
            pattern = "{pkg}",
            replacement = pkg,
            x = setdiff(x = there, y = here),
            fixed = TRUE
          ),
          message = "the reference has this file (project-specific: write it)"
        ),
        .ConformRow(
          rule = "file-set-extra",
          class = "info",
          file = gsub(
            pattern = "{pkg}",
            replacement = pkg,
            x = setdiff(x = here, y = there),
            fixed = TRUE
          ),
          message = "the reference does not have this file"
        )
      )
    )
  }
}
