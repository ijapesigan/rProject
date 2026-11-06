#' Build README.md
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @inheritParams Bib
#' @return Called for its side effects; the value is not meaningful.
#' @examples
#' \dontrun{
#' ReadMe(path = getwd())
#' }
#' @export
ReadMe <- function(path) {
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
      Bib(
        path = path,
        bib_lib = FALSE
      )
    }
    try(
      expr = file.copy(
        from = bib,
        to = path
      )
    )
    try(
      expr = file.rename(
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
    # the badges follow the project's workflows
    .BadgesWrite(path = path)
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
