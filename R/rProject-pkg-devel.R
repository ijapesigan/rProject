#' Install Development Packages from CRAN
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @return Called for its side effects; the value is not meaningful.
#' @examples
#' \dontrun{
#' PkgDevel(path = getwd())
#' }
#' @export
PkgDevel <- function(path) {
  pkg <- c(
    "BiocManager",
    "cffr",
    "covr",
    "devtools",
    "distro",
    "ggplot2",
    "DT",
    "knitr",
    "lintr",
    "magick",
    "markdown",
    "microbenchmark",
    "pdftools",
    "pkgdown",
    "printr",
    "qpdf",
    "quarto",
    "ragg",
    "Rcpp",
    "remotes",
    "rhub",
    "rmarkdown",
    "roxygen2",
    "rprojroot",
    "styler",
    "testthat",
    "tidyverse",
    "tinytex"
  )
  lib <- LibPaths(path = path)
  installed <- utils::installed.packages()
  pkg_installed <- installed[, "Package"]
  for (i in seq_along(along.with = pkg)) {
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
        pkgs = pkg[i],
        repos = c(REPO_NAME = PkgRepo(path = path)),
        lib = lib,
        quiet = TRUE
      )
    }
  }
}
