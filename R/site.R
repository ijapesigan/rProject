#' Build Website
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @export
Site <- function(path) {
  if (
    file.exists(
      file.path(
        path,
        "DESCRIPTION"
      )
    )
  ) {
    lib <- LibPaths(path = path)
    installed <- utils::installed.packages()
    pkg_installed <- installed[, "Package"]
    if (!("devtools" %in% pkg_installed)) {
      remotes::install_github(
        repo = "r-lib/devtools",
        lib = lib,
        quiet = TRUE
      )
    }
    if (!("pkgdown" %in% pkg_installed)) {
      utils::install.packages(
        "pkgdown",
        repos = c(REPO_NAME = PkgRepo(path = path)),
        lib = lib,
        quiet = TRUE
      )
    }
    if (
      file.exists(
        file.path(
          path,
          "README.Rmd"
        )
      )
    ) {
      devtools::build_readme(
        path = path
      )
    }
    if (
      file.exists(
        file.path(
          path,
          "_pkgdown.yml"
        )
      )
    ) {
      pkgdown::build_site(
        pkg = path,
        preview = FALSE
      )
    }
  } else {
    message(
      paste(
        path,
        "is not an R package."
      )
    )
  }
}
