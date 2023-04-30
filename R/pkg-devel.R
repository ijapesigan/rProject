#' Install Development Packages from CRAN
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @export
PkgDevel <- function(path) {
  pkg <- c(
    "cffr",
    "covr",
    "devtools",
    "distro",
    "ggplot2",
    "knitr",
    "lintr",
    "magick",
    "microbenchmark",
    "pdftools",
    "pkgdown",
    "ragg",
    "remotes",
    "rmarkdown",
    "rprojroot",
    "styler",
    "testthat",
    "tidyverse",
    "qpdf"
  )
  lib <- LibPaths(path = path)
  installed <- utils::installed.packages()
  pkg_installed <- installed[, "Package"]
  for (i in seq_along(pkg)) {
    if (!(pkg[i] %in% pkg_installed)) {
      cat(
        paste0(
          "Installing ",
          pkg[i],
          "...",
          "\n"
        )
      )
      utils::install.packages(
        pkg[i],
        repos = c(REPO_NAME = PkgRepo(path = path)),
        lib = lib,
        quiet = TRUE
      )
    }
  }
}
