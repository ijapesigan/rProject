#' Build `.Rbuildignore`
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @inheritParams EnvironmentProject
#' @param add Character vector.
#'   Items to add in `.Rbuildignore`.
#' @export
BuildIgnore <- function(path,
                        project,
                        add = NULL) {
  x <- c(
    ".*\\.Rcheck$",
    ".*\\.Rproj$",
    ".*\\.sh$",
    ".*\\.sif$",
    ".*\\.tar\\.gz$",
    ".*\\.tar\\.xz$",
    ".*\\.tgz$",
    ".*\\.uuid$",
    ".*\\.yml$",
    "^CITATION.cff$",
    "^LICENSE.md$",
    "^Makefile$",
    "^README.md$",
    "^README.Rmd$",
    "^\\.data-.*$",
    "^\\.Rproj\\.user$",
    "^\\.covrignore$",
    "^\\.dotfiles$",
    "^\\.git.*$",
    "^\\.library$",
    "^\\.lintr$",
    "^\\.project$",
    "^\\.secrets$",
    "^\\.setup$",
    "^\\.sim$",
    "^detritus$",
    "^docs$",
    "^latex.*$",
    "^make.*$",
    paste0(
      "^",
      project,
      ".pdf$"
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
