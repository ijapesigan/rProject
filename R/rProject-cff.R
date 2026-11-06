#' Build `CITATION.cff`
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @return Called for its side effects; the value is not meaningful.
#' @examples
#' \dontrun{
#' CFF(path = getwd())
#' }
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
    # cffr reads the DESCRIPTION file, not the folder, and writes outfile
    # relative to the working directory; both are given in full
    cffr::cff_write(
      x = file.path(
        path,
        "DESCRIPTION"
      ),
      outfile = file.path(
        path,
        "CITATION.cff"
      ),
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
