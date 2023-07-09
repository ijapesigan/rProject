#' Code Coverage
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @export
Coverage <- function(path) {
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
    if (!("covr" %in% pkg_installed)) {
      utils::install.packages(
        "covr",
        repos = c(REPO_NAME = PkgRepo(path = path)),
        lib = lib,
        quiet = TRUE
      )
    }
    output <- file.path(
      path,
      ".setup",
      "coverage",
      ".covrignore"
    )
    file.copy(
      from = output,
      to = path
    )
    covr::package_coverage(path = path)
    on.exit(
      expr = unlink(
        x = output
      ),
      add = TRUE
    )
  } else {
    message(
      paste(
        path,
        "is not an R package."
      )
    )
  }
}
