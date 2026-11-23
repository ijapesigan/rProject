#' Code Coverage
#'
#' Runs `covr::package_coverage()` on the package. To leave files out,
#' put covr's `.covrignore` at the project root (and add it to
#' `.Rbuildignore` with `ignore` in `.setup/scripts/project.R`).
#' The tests run with `NOT_CRAN=true`, as under `devtools::test()`, so
#' that `testthat::skip_on_cran()` does not skip them.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @return Called for its side effects; the value is not meaningful.
#' @examples
#' \dontrun{
#' Coverage(path = getwd())
#' }
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
        pkgs = "covr",
        repos = c(REPO_NAME = PkgRepo(path = path)),
        lib = lib,
        quiet = TRUE
      )
    }
    # covr runs the tests without devtools, so nothing sets NOT_CRAN, and
    # skip_on_cran() skips most tests (0% to 40% under Slurm): set it for
    # the run, and restore it on exit
    not_cran <- Sys.getenv(x = "NOT_CRAN", unset = NA)
    Sys.setenv(NOT_CRAN = "true")
    on.exit(
      expr = if (is.na(x = not_cran)) {
        Sys.unsetenv(x = "NOT_CRAN")
      } else {
        Sys.setenv(NOT_CRAN = not_cran)
      },
      add = TRUE
    )
    covr::package_coverage(path = path)
  } else {
    message(
      paste(
        path,
        "is not an R package."
      )
    )
  }
}
