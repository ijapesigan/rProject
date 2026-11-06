#' Install Project Packages from CRAN
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @param pkg Character vector.
#'   R packages.
#' @return Called for its side effects; the value is not meaningful.
#' @examples
#' \dontrun{
#' PkgProject(path = getwd(), pkg = "stats")
#' }
#' @export
PkgProject <- function(path,
                       pkg) {
  lib <- LibPaths(path = path)
  installed <- utils::installed.packages()
  pkg_installed <- installed[, "Package"]
  if (length(x = pkg) > 0) {
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
}
