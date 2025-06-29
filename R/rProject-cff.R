#' Build `CITATION.cff`
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @export
CFF <- function(path) {
  if (
    file.exists(
      file.path(
        path,
        "DESCRIPTION"
      )
    )
  ) {
    cffr::cff_write(
      x = path,
      gh_keywords = TRUE,
      dependencies = FALSE,
      validate = TRUE,
      verbose = TRUE
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
