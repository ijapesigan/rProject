#' Build Website
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @inheritParams Bib
#' @export
Site <- function(path,
                 lib_bib = FALSE) {
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
      remotes::install_github(
        repo = "r-lib/devtools",
        lib = lib,
        quiet = TRUE
      )
    }
    if (!("pkgdown" %in% pkg_installed)) {
      utils::install.packages(
        "pkgdown",
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
      Bib(path = path, lib_bib = lib_bib)
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
          file.path(
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
