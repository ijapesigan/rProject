#' Copy Dependencies to from `.setup/r-dependencies` to `R`
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
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
    if (length(deps) > 0) {
      file.copy(
        from = deps,
        to = file.path(
          path,
          "R"
        )
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
