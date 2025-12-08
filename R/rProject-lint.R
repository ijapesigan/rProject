#' Lint Project
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @export
Lint <- function(path) {
  path_lintr <- file.path(
    path,
    ".lintr"
  )
  on.exit(
    expr = unlink(
      x = path_lintr
    ),
    add = TRUE
  )
  unlink(x = path_lintr)
  setup_lint <- file.path(
    path,
    ".setup",
    "lint"
  )
  unlink(x = setup_lint, recursive = TRUE)
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
    "linters: lintr::linters_with_defaults(\n",
    "    lintr::object_name_linter(\n",
    "      styles = c(\"CamelCase\", \"snake_case\", \"symbols\")\n",
    "    )\n",
    "  )\n",
    "exclusions: list(\n",
    "    \"renv\",\n",
    "    \"packrat\",\n",
    "    \".library\",\n",
    "    \"R/RcppExports.R\"\n",
    "  )\n"
  )
  con <- file(path_lintr)
  writeLines(
    text = x,
    con = con,
    sep = "\n"
  )
  close(con)
  dir.create(
    path = setup_lint,
    showWarnings = FALSE,
    recursive = TRUE
  )
  file.copy(
    from = path_lintr,
    to = setup_lint,
    overwrite = TRUE
  )
  file.rename(
    from = file.path(setup_lint, ".lintr"),
    to = file.path(setup_lint, "lintr")
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
    from = path_lintr,
    to = linters,
    overwrite = TRUE
  )
  lintr::lint_dir(
    path = path,
    exclusions = list(
      "renv",
      "packrat",
      ".library",
      "R/RcppExports.R"
    )
  )
}
