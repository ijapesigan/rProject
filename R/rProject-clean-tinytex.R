#' Clean `~/.TinyTex`
#'
#' Uninstall `TinyTex`.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @export
CleanTinyTex <- function(path) {
  lib <- LibPaths(path = path)
  installed <- utils::installed.packages()
  pkg_installed <- installed[, "Package"]
  install_tinytex <- !("tinytex" %in% pkg_installed)
  if (install_tinytex) {
    install_remotes <- !("remotes" %in% pkg_installed)
    if (install_remotes) {
      utils::install.packages(
        "remotes",
        repos = c(REPO_NAME = PkgRepo(path = path)),
        lib = lib,
        quiet = TRUE
      )
    }
    remotes::install_github(
      repo = "rstudio/tinytex",
      lib = lib,
      quiet = TRUE
    )
  }
  try(
    tinytex::uninstall_tinytex(force = TRUE)
  )
  if (install_tinytex) {
    if (install_remotes) {
      utils::remove.packages("remotes")
    }
    utils::remove.packages("tinytex")
  }
}
