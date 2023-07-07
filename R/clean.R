#' Clean Files Generated on Build
#'
#' Delete all output files that are generated on automated build.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @export
Clean <- function(path) {
  unlink(
    file.path(
      path,
      c(
        ".quarto",
        "detritus",
        "doc",
        "docs",
        "man",
        "pkgdown",
        "quarto",
        "TEMPDIR",
        "_site",
        file.path(
          "latexsrc",
          "pdf"
        )
      )
    )
  )
  files <- file.path(
    path,
    c(
      "README.html",
      "README.md",
      "README.knit.md",
      "NAMESPACE",
      ".lintr"
    )
  )
  files <- c(
    files,
    list.files(
      file.path(
        path
      ),
      pattern = utils::glob2rx("fig-vignettes-*"),
      full.names = TRUE
    ),
    list.files(
      file.path(
        path
      ),
      pattern = utils::glob2rx("*.pdf"),
      full.names = TRUE
    ),
    list.files(
      file.path(
        path
      ),
      pattern = utils::glob2rx("*.tar.gz"),
      full.names = TRUE
    ),
    list.files(
      file.path(
        path
      ),
      pattern = utils::glob2rx("*.cff"),
      full.names = TRUE
    )
  )
  unlink(files)
}
