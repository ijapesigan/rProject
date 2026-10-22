#' Setup Binaries not Included in the Package
#'
#' Runs (sources) every R script in `.setup/bin/`, at `make project`; for
#' example, a script that builds a bespoke binary the project needs.
#' `.setup/bin/` is optional: `make` does not create it, and without it
#' `Binary()` does nothing.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @export
Binary <- function(path) {
  x <- list.files(
    path = file.path(
      path,
      ".setup",
      "bin"
    ),
    pattern = "\\.R$",
    full.names = TRUE,
    all.files = TRUE,
    recursive = TRUE
  )
  if (length(x) > 0) {
    invisible(
      lapply(
        X = x,
        FUN = source
      )
    )
  }
}
