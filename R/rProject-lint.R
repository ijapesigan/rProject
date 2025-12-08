#' Lint Project
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @export
Lint <- function(path) {
  wd <- getwd()
  setwd(path)
  on.exit(
    expr = setwd(wd),
    add = TRUE
  )
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
    "  )\n"
  )
  lintr <- file.path(
    path,
    ".lintr"
  )
  on.exit(
    expr = unlink(
      x = lintr
    ),
    add = TRUE
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
  file.rename(
    from = file.path(lint, ".lintr"),
    to = file.path(lint, "lintr")
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
  lintr::lint_dir(
    path = path,
    exclusions = list(
      "renv",
      "packrat",
      ".library"
    )
  )
}
