#' Build Website
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @inheritParams Bib
#' @return Called for its side effects; the value is not meaningful.
#' @examples
#' \dontrun{
#' Site(path = getwd())
#' }
#' @export
Site <- function(path) {
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
    if (!("devtools" %in% pkg_installed)) {
      pak::pkg_install(
        pkg = "r-lib/devtools",
        lib = lib,
        upgrade = FALSE
      )
    }
    if (!("pkgdown" %in% pkg_installed)) {
      utils::install.packages(
        pkgs = "pkgdown",
        repos = c(REPO_NAME = PkgRepo(path = path)),
        lib = lib,
        quiet = TRUE
      )
    }
    pkgdown <- file.path(
      path,
      ".setup",
      "pkgdown",
      "_pkgdown.yml"
    )
    if (
      file.exists(
        pkgdown
      )
    ) {
      bib <- file.path(
        path,
        "vignettes",
        "vignettes.bib"
      )
      if (!file.exists(bib)) {
        Bib(
          path = path,
          bib_lib = FALSE
        )
      }
      file.copy(
        from = pkgdown,
        to = path
      )
      pkgdown::build_site(
        pkg = path,
        preview = FALSE
      )
      on.exit(
        expr = unlink(
          x = file.path(
            path,
            "_pkgdown.yml"
          )
        ),
        add = TRUE
      )
    } else {
      message(
        paste(
          pkgdown,
          "does not exist."
        )
      )
    }
  } else {
    message(
      paste(
        path,
        "is not an R package."
      )
    )
  }
}
