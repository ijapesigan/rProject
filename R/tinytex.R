#' Install `~/.TinyTex`
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @param force Logical.
#'   Force install.
#' @export
TinyTex <- function(path,
                    force = FALSE) {
  install <- FALSE
  lib <- LibPaths(path = path)
  installed <- utils::installed.packages()
  pkg_installed <- installed[, "Package"]
  if (!("remotes" %in% pkg_installed)) {
    utils::install.packages(
      "remotes",
      repos = c(REPO_NAME = PkgRepo(path = path)),
      lib = lib,
      quiet = TRUE
    )
  }
  run <- FALSE
  if (!("tinytex" %in% pkg_installed)) {
    run <- TRUE
  } else {
    if (is.null(utils::packageDescription("tinytex")$GithubRepo)) {
      run <- TRUE
    }
  }
  if (run) {
    remotes::install_github(
      repo = "rstudio/tinytex",
      lib = lib,
      quiet = TRUE
    )
  }
  if (!tinytex::is_tinytex()) {
    install <- TRUE
  }
  if (force) {
    install <- TRUE
  }
  if (install) {
    tinytex::install_tinytex(
      bundle = "TinyTeX-2",
      force = TRUE
    )
  }
}
