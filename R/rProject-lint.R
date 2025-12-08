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
  x <- paste0(
    "linters:",
    " ",
    "lintr::linters_with_defaults(",
    "lintr::object_name_linter(",
    "styles",
    " ",
    "=",
    " ",
    "c(",
    "\"CamelCase\", \"snake_case\", \"symbols\"",
    ")",
    ")",
    ")",
    "\n",
    "exclusions: list(",
    "\"renv\", \"packrat\", \".library\", \"R/RcppExports.R\"",
    ")",
    "\n"
  )
  lintr <- file.path(
    path,
    ".lintr"
  )
  con <- file(lintr)
  writeLines(
    text = x,
    con = con,
    sep = "\n"
  )
  close(con)
  lint <- file.path(
    path,
    ".setup",
    "lint"
  )
  dir.create(
    path = lint,
    showWarnings = FALSE,
    recursive = TRUE
  )
  file.copy(
    from = lintr,
    to = lint,
    overwrite = TRUE
  )
  linters <- file.path(
    ".github",
    "linters"
  )
  dir.create(
    path = file.path(
      ".github",
      "linters"
    ),
    showWarnings = FALSE,
    recursive = TRUE
  )
  file.copy(
    from = lintr,
    to = linters,
    overwrite = TRUE
  )
  on.exit(
    expr = unlink(
      x = lintr
    ),
    add = TRUE
  )
  lintr::lint_dir(
    path = path,
    exclusions = c(
      "renv",
      "packrat",
      ".library",
      "R/RcppExports.R"
    )
  )
}
