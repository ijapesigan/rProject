#' Copy Dependencies to from `.setup/r-dependencies` to `R`
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @return Called for its side effects; the value is not meaningful.
#' @examples
#' \dontrun{
#' Dependencies(path = getwd())
#' }
#' @export
Dependencies <- function(path) {
  if (
    file.exists(
      file.path(
        path,
        "DESCRIPTION"
      )
    )
  ) {
    deps <- list.files(
      path = file.path(
        path,
        ".setup",
        "r-dependencies"
      ),
      pattern = "\\.R$",
      full.names = TRUE,
      all.files = TRUE,
      recursive = TRUE
    )
    if (length(x = deps) > 0) {
      file.copy(
        from = deps,
        to = file.path(
          path,
          "R"
        ),
        overwrite = TRUE
      )
    }
  } else {
    message(
      paste(
        path,
        "is not an R package."
      )
    )
  }
}
