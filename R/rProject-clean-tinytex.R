#' Clean `~/.TinyTex`
#'
#' Uninstall `TinyTex`.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @return Called for its side effects; the value is not meaningful.
#' @examples
#' \dontrun{
#' CleanTinyTex(path = getwd())
#' }
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
        pkgs = "remotes",
        repos = c(REPO_NAME = PkgRepo(path = path)),
        lib = lib,
        quiet = TRUE
      )
    }
    pak::pkg_install(
      pkg = "rstudio/tinytex",
      lib = lib,
      upgrade = FALSE
    )
  }
  try(
    expr = tinytex::uninstall_tinytex(force = TRUE)
  )
  if (install_tinytex) {
    if (install_remotes) {
      utils::remove.packages(pkgs = "remotes")
    }
    utils::remove.packages(pkgs = "tinytex")
  }
}
