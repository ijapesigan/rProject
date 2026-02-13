#' Build Package
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @inheritParams Bib
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
      pak::pkg_install(
        pkg = "r-lib/devtools",
        lib = lib
      )
    }
    bib <- file.path(
      path,
      "vignettes",
      "bib.bib"
    )
    if (!file.exists(bib)) {
      Bib(
        path = path,
        bib_lib = FALSE
      )
    }
    cpp <- list.files(
      path = file.path(path, ".setup", "cpp"),
      pattern = "^.*\\.cpp",
      full.names = TRUE
    )
    if (length(cpp) > 0) {
      dir.create(
        path = file.path(path, "src"),
        showWarnings = FALSE,
        recursive = TRUE
      )
      unlink(
        file.path(
          path,
          "R",
          "RcppExports.R"
        )
      )
      unlink(
        file.path(
          path,
          "src",
          "RcppExports.cpp"
        )
      )
      namespace <- file.path(
        path,
        "NAMESPACE"
      )
      if (!file.exists(namespace)) {
        file.create(namespace)
      }
      cpp_file_fn <- file.path(
        path,
        "src",
        "source.cpp"
      )
      cpp_file <- file(
        description = cpp_file_fn,
        open = "w"
      )
      for (i in seq_along(cpp)) {
        writeLines(
          text = readLines(con = cpp[i]),
          con = cpp_file
        )
      }
      file.copy(
        from = file.path(path, ".setup", "cpp", "Makevars"),
        to = file.path(path, "src")
      )
      file.copy(
        from = file.path(path, ".setup", "cpp", "Makevars.win"),
        to = file.path(path, "src")
      )
      close(cpp_file)
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
