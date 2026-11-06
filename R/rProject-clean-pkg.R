#' Clean R Packages
#'
#' Remove the project's R library (`.library`).
#' Packages outside the project (the image's site library,
#' the user library) are never touched.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @return Called for its side effects; the value is not meaningful.
#' @examples
#' \dontrun{
#' CleanPkg(path = getwd())
#' }
#' @export
CleanPkg <- function(path) {
  lib <- LibPaths(path = path)
  unlink(
    x = lib,
    recursive = TRUE,
    force = FALSE
  )
  invisible(x = LibPaths(path = path))
}
