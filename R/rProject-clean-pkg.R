#' Clean R Packages
#'
#' Uninstall R packages with `priority = "NA"`.
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
  other_libs <- .libPaths()
  for (i in seq_along(other_libs)) {
    if (other_libs[i] == lib) {
      other_libs[i] <- NA
    }
  }
  other_libs <- other_libs[stats::complete.cases(other_libs)]
  for (i in seq_along(other_libs)) {
    pkgs_i <- utils::installed.packages(
      priority = "NA",
      lib = other_libs[i]
    )
    pkgs_i <- pkgs_i[, "Package"]
    if (length(pkgs_i) != 0) {
      utils::remove.packages(
        pkgs = pkgs_i,
        lib = other_libs[i]
      )
    }
  }
  invisible(LibPaths(path = path))
}
