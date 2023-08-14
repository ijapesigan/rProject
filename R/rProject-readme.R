#' Build README.md
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @inheritParams Bib
#' @export
ReadMe <- function(path,
                   lib_bib = FALSE) {
  readme <- file.path(
    path,
    ".setup",
    "readme",
    "README.Rmd"
  )
  if (file.exists(readme)) {
    bib <- file.path(
      path,
      ".setup",
      "latex",
      "bib",
      "bib.bib"
    )
    if (!file.exists(bib)) {
      Bib(path = path, lib_bib = lib_bib)
    }
    try(
      file.copy(
        from = bib,
        to = path
      )
    )
    try(
      file.rename(
        from = file.path(
          path,
          "bib.bib"
        ),
        to = file.path(
          path,
          "vignettes.bib"
        )
      )
    )
    file.copy(
      from = readme,
      to = path
    )
    readme_rmd <- file.path(
      path,
      "README.Rmd"
    )
    readme_md <- file.path(
      path,
      "README.md"
    )
    rmarkdown::render(
      input = readme_rmd,
      output_format = "github_document",
      output_file = readme_md
    )
    on.exit(
      expr = unlink(
        x = c(
          readme_rmd,
          file.path(
            path,
            "vignettes.bib"
          ),
          file.path(
            path,
            "README.html"
          ),
          file.path(
            path,
            "README.knit.md"
          ),
          file.path(
            path,
            "README_files"
          )
        ),
        recursive = TRUE
      ),
      add = TRUE
    )
  }
}
