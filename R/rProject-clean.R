#' Clean Files Generated on Build
#'
#' Delete all output files that are generated on automated build.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @param push Logical.
#'   If `push = TRUE` clean in preparation for git push.
#' @export
Clean <- function(path,
                  push = FALSE) {
  if (push) {
    files <- list.files(
      path = path,
      pattern = ".*secrets.*",
      full.names = TRUE,
      recursive = TRUE
    )
    unlink(
      x = c(
        files,
        file.path(
          path,
          "latexmkrc"
        )
      ),
      recursive = TRUE
    )
  }
  unlink(
    x = file.path(
      path,
      c(
        ".covrignore",
        ".lintr",
        ".quarto",
        "_pkgdown.yml",
        "_publish.yml",
        "_quarto.yml",
        "detritus",
        "doc",
        "docs",
        "latexmkrc",
        "pkgdown",
        "quarto",
        "README.html",
        "README.knit.md",
        "TEMPDIR",
        "_site",
        file.path(
          ".setup",
          "notes"
        ),
        file.path(
          ".setup",
          "latex",
          "bib",
          "bib.bib"
        ),
        file.path(
          ".setup",
          "quarto",
          "bib",
          "quarto.bib"
        ),
        file.path(
          ".setup",
          "pkgdown",
          "vignettes.bib"
        ),
        file.path(
          "vignettes",
          "vignettes.bib"
        ),
        file.path(
          ".setup",
          "latex",
          "pdf"
        )
      )
    ),
    recursive = TRUE
  )
  if (!push) {
    unlink(
      x = file.path(
        path,
        c(
          "man",
          "NAMESPACE",
          "README.md",
          "_site",
          file.path(
            ".setup",
            "build"
          )
        )
      ),
      recursive = TRUE
    )
  }
  files <- c(
    list.files(
      path = path,
      pattern = "^fig-vignettes-.*$",
      full.names = TRUE
    ),
    list.files(
      path = path,
      pattern = ".*\\.pdf$",
      full.names = TRUE
    ),
    list.files(
      path = path,
      pattern = ".*\\.tar\\.gz$",
      full.names = TRUE
    ),
    list.files(
      path = file.path(path, "src"),
      pattern = ".*\\.o$",
      full.names = TRUE
    ),
    list.files(
      path = file.path(path, "src"),
      pattern = ".*\\.so$",
      full.names = TRUE
    ),
    list.files(
      path = file.path(path, "src"),
      pattern = ".*\\.dll$",
      full.names = TRUE
    )
  )
  unlink(x = files)
  if (!push) {
    files <- c(
      list.files(
        path = path,
        pattern = ".*\\.cff$",
        full.names = TRUE
      )
    )
    unlink(x = files)
  }
}
