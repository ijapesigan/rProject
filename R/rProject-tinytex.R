#' Install `~/.TinyTex`
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @inheritParams tinytex::install_tinytex
#' @param force Logical.
#'   Force install.
#' @export
TinyTex <- function(path,
                    bundle = "TinyTeX-2",
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
    pak::pkg_install(
      pkg = "rstudio/tinytex",
      lib = lib
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
      bundle = bundle,
      force = TRUE
    )
  }
}
