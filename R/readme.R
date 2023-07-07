#' Build README.md
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @export
ReadMe <- function(path) {
  readme_rmd <- file.path(
    path,
    "README.Rmd"
  )
  readme_md <- file.path(
    path,
    "README.md"
  )
  if (
    file.exists(
      readme_rmd
    )
  ) {
    rmarkdown::render(
      input = readme_rmd,
      output_format = "github_document",
      output_file = readme_md
    )
  }
  unlink(
    c(
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
    )
  )
}
