#' Install Project Packages from CRAN
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @param pkg Character vector.
#'   R packages.
#' @export
PkgProject <- function(path,
                       pkg) {
  lib <- LibPaths(path = path)
  installed <- utils::installed.packages()
  pkg_installed <- installed[, "Package"]
  if (length(pkg) > 0) {
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
}
