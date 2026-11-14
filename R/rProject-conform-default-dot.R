.ConformDefault <- function(path,
                            file) {
  # the text of a required file that the template does not keep as a
  # manifest row; NULL when there is none
  pkg <- .LintPkg(path = path)
  if (identical(x = file, y = "vignettes/.gitignore")) {
    "*.Rds"
  } else if (identical(x = file, y = "tests/testthat.R")) {
    c(
      "library(testthat)",
      paste0("library(", pkg, ")"),
      "",
      paste0("test_check(\"", pkg, "\")")
    )
  } else if (identical(x = file, y = "inst/CITATION")) {
    readLines(
      con = system.file(
        "template",
        "once",
        "citation-default.txt",
        package = "rProject",
        mustWork = TRUE
      ),
      warn = FALSE
    )
  } else if (identical(x = file, y = ".setup/pkgdown/_pkgdown.yml")) {
    public <- .RepoInfo(path = path)$public_github
    parts <- strsplit(x = c(public, "")[1], split = "/", fixed = TRUE)[[1]]
    c(
      "destination: pkgdown",
      if (length(x = parts) == 2L) {
        paste0("url: https://", parts[1], ".github.io/", parts[2], "/")
      },
      "",
      "template:",
      "  package: rProject",
      "",
      "articles:",
      "- title: Getting Started",
      "  contents:",
      paste0("  - ", pkg),
      "- title: Session Information",
      "  contents:",
      "  - session"
    )
  }
}
