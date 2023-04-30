#' Style Project
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @export
Style <- function(path) {
  lib <- LibPaths(path = path)
  installed <- utils::installed.packages()
  pkg_installed <- installed[, "Package"]
  if (!("styler" %in% pkg_installed)) {
    utils::install.packages(
      "styler",
      repos = c(REPO_NAME = PkgRepo(path = path)),
      lib = lib,
      quiet = TRUE
    )
  }
  styler::style_dir(
    path = path,
    exclude_dirs = c(
      ".library",
      file.path(
        ".setup",
        "notes"
      ),
      "renv",
      "packrat"
    )
  )
}
