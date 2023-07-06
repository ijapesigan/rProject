#' Build Package
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @param vignettes Logical.
#'   Build vignettes.
#' @param dependencies Logical.
#'   Install package dependencies.
#' @export
Build <- function(path,
                  vignettes = FALSE,
                  dependencies = FALSE) {
  lib <- LibPaths(path = path)
  installed <- utils::installed.packages()
  pkg_installed <- installed[, "Package"]
  if (!("devtools" %in% pkg_installed)) {
    remotes::install_github(
      repo = "r-lib/devtools",
      lib = lib,
      quiet = TRUE
    )
  }
  if (
    file.exists(
      file.path(
        path,
        "DESCRIPTION"
      )
    )
  ) {
    devtools::document(pkg = path)
    devtools::check(pkg = path, cran = FALSE)
    devtools::install(pkg = path, dependencies = dependencies)
    devtools::build(
      pkg = path,
      path = path,
      manual = TRUE,
      vignettes = vignettes
    )
  }
}
