#' Lint Project
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @export
Lint <- function(path) {
  lib <- LibPaths(path = path)
  installed <- utils::installed.packages()
  pkg_installed <- installed[, "Package"]
  if (!("lintr" %in% pkg_installed)) {
    utils::install.packages(
      "lintr",
      repos = c(REPO_NAME = PkgRepo(path = path)),
      lib = lib,
      quiet = TRUE
    )
  }
  lintr::lint_dir(
    path = path,
    linters = lintr::linters_with_defaults(
      lintr::object_name_linter(
        styles = c(
          "CamelCase",
          "snake_case",
          "symbols"
        )
      )
    ),
    exclusions = list(
      "renv",
      "packrat",
      ".library",
      "R/RcppExports.R"
    )
  )
}
