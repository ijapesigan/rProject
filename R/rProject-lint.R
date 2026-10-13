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
  # the files to skip, as full paths: lintr (3.4.0) fails on an excluded
  # folder that holds no R files
  exclusions <- c(
    unlist(
      lapply(
        X = file.path(path, c("renv", "packrat", ".library", ".verify")),
        FUN = list.files,
        pattern = "\\.(r|rmd|qmd|rnw|rhtml|rrst|rtex|rtxt)$",
        ignore.case = TRUE,
        all.files = TRUE,
        recursive = TRUE,
        full.names = TRUE
      )
    ),
    file.path(path, "R", "RcppExports.R")
  )
  exclusions <- exclusions[file.exists(exclusions)]
  # no try(): an error in lintr stops make lint
  if (length(exclusions) == 0L) {
    lints <- lintr::lint_dir(
      path = path,
      linters = linters
    )
  } else {
    lints <- lintr::lint_dir(
      path = path,
      linters = linters,
      exclusions = exclusions
    )
  }
  # lib-* projects: check the entries too (reported, not an error)
  project <- .VerifyProject(path = path)
  if (grepl(pattern = "^lib-[0-9]{4}-[0-9]{4}-[a-z]+$", x = project)) {
    print(LibCheck(path = path))
  }
  lints
}
