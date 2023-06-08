#' Install Project Packages from GitHub
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @param pkg Character vector.
#'   GitHub packages.
#' @param ref Character vector.
#'   Git branch.
#' @export
PkgProjectGitHub <- function(path,
                             pkg,
                             ref = "HEAD") {
  lib <- LibPaths(path = path)
  if (length(ref) == 1) {
    if (ref == "HEAD") {
      ref <- rep(
        x = ref,
        times = length(pkg)
      )
    }
  }
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
  for (i in seq_along(pkg)) {
    cat(
      paste0(
        "Installing ",
        pkg[i],
        "...",
        "\n"
      )
    )
    remotes::install_github(
      repo = pkg[i],
      ref = ref[i],
      lib = lib,
      quiet = TRUE
    )
  }
}
