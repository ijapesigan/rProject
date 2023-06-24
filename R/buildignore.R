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
  x <- c(
    ".*\\.Rcheck$",
    ".*\\.Rproj$",
    ".*\\.sif$",
    ".*\\.tar\\.gz$",
    ".*\\.tar\\.xz$",
    ".*\\.tgz$",
    ".*\\.uuid$",
    ".*\\.yml$",
    "^CITATION\\.cff$",
    "^LICENSE\\.md$",
    "^Makefile$",
    "^README\\.Rmd$",
    "^README\\.md$",
    "^\\.Rproj\\.user$",
    "^\\.covrignore$",
    "^\\.data-.*$",
    "^\\.devcontainer$",
    "^\\.git.*$",
    "^\\.library$",
    "^\\.lintr$",
    "^\\.setup$",
    "^\\.sim$",
    "^detritus$",
    "^docs$",
    "^index\\.qmd$",
    "^latex.*$",
    "^scss$",
    "^qmd$",
    paste0(
      "^",
      project,
      "\\.pdf$"
    )
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
}
