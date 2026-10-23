#' Clean R Packages
#'
#' Remove the project's R library (`.library`).
#' Packages outside the project (the image's site library,
#' the user library) are never touched.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @export
CleanPkg <- function(path) {
  lib <- LibPaths(path = path)
  unlink(
    x = lib,
    recursive = TRUE,
    force = FALSE
  )
  invisible(LibPaths(path = path))
}
