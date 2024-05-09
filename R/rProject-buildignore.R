#' Build `.Rbuildignore`
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @inheritParams EnvironmentProject
#' @param add Character vector.
#'   Items to add to `.Rbuildignore`.
#' @export
BuildIgnore <- function(path,
                        project,
                        add = NULL) {
  if (
    file.exists(
      file.path(
        path,
        "DESCRIPTION"
      )
    )
  ) {
    x <- c(
      ".*\\.Rcheck$",
      ".*\\.Rproj$",
      ".*\\.sif$",
      "^CITATION\\.cff$",
      "^LICENSE\\.md$",
      "^Makefile$",
      "^README\\.Rmd$",
      "^README\\.md$",
      "^\\.Rproj\\.user$",
      "^\\.devcontainer$",
      "^\\.git.*$",
      "^\\.library$",
      "^\\.setup$",
      "^\\.sif$",
      "^\\.sim$",
      "^detritus$",
      "^index\\.qmd$",
      "^pkgdown$",
      "^quarto$",
      "^scripts$"
    )
    if (!is.null(add)) {
      x <- c(x, add)
    }
    con <- file(
      file.path(
        path,
        ".Rbuildignore"
      )
    )
    writeLines(
      text = x,
      con = con,
      sep = "\n"
    )
    close(con)
  } else {
    message(
      paste(
        path,
        "is not an R package."
      )
    )
  }
}
