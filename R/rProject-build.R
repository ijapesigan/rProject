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
    bib <- file.path(
      path,
      "vignettes",
      "bib.bib"
    )
    if (!file.exists(bib)) {
      Bib(path = path)
    }
    cpp <- list.files(
      path = file.path(path, "src"),
      pattern = "^.*\\.cpp"
    )
    if (length(cpp) > 0) {
      namespace <- file.path(
        path,
        "NAMESPACE"
      )
      if (!file.exists(namespace)) {
        file.create(namespace)
      }
      Rcpp::compileAttributes(pkgdir = path)
      roxygen2::roxygenize(
        package.dir = path,
        roclets = "rd"
      )
      unlink(namespace)
    }
    devtools::document(pkg = path)
    devtools::check(pkg = path, cran = FALSE)
    devtools::install(pkg = path, dependencies = dependencies)
    output <- file.path(
      path,
      ".setup",
      "build"
    )
    unlink(
      x = list.files(
        output,
        pattern = utils::glob2rx("*.tar.gz"),
        full.names = TRUE
      )
    )
    dir.create(
      path = output,
      showWarnings = FALSE,
      recursive = TRUE
    )
    devtools::build(
      pkg = path,
      path = output,
      manual = TRUE,
      vignettes = vignettes
    )
  } else {
    message(
      paste(
        path,
        "is not an R package."
      )
    )
  }
}
