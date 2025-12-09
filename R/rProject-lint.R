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
  linters <- lintr::linters_with_defaults(
    lintr::object_name_linter(
      styles = c(
        "CamelCase",
        "snake_case",
        "symbols"
      )
    )
  )
  exclusions <- list(
    "renv",
    "packrat",
    ".library",
    file.path("R", "RcppExports.R")
  )
  keep <- vapply(
    X = exclusions,
    FUN = function(x) file.exists(x),
    FUN.VALUE = logical(1)
  )
  exclusions <- exclusions[keep]
  if (length(exclusions) == 0L) {
    lintr::lint_dir(
      path = path,
      linters = linters
    )
  } else {
    lintr::lint_dir(
      path = path,
      linters = linters,
      exclusions = exclusions
    )
  }
}
