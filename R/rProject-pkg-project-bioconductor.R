#' Install Project Packages from Bioconductor
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @param pkg Character vector.
#'   Bioconductor packages.
#' @export
PkgProjectBioconductor <- function(path,
                                   pkg) {
  lib <- LibPaths(path = path)
  installed <- utils::installed.packages()
  pkg_installed <- installed[, "Package"]
  if (length(pkg) > 0) {
    for (i in seq_along(pkg)) {
      if (!(pkg[i] %in% pkg_installed)) {
        cat(
          paste0(
            "Installing ",
            pkg[i],
            "...",
            "\n"
          )
        )
        BiocManager::install(
          pkgs = pkg[i],
          lib = lib,
          quiet = TRUE
        )
      }
    }
  }
}
