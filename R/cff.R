#' Build `CITATION.cff`
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @export
CFF <- function(path) {
  cffr::cff_write(
    x = path,
    gh_keywords = TRUE,
    dependencies = FALSE,
    validate = TRUE,
    verbose = TRUE
  )
}
