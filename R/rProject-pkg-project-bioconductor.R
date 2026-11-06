#' Install Project Packages from Bioconductor
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @param pkg Character vector.
#'   Bioconductor packages.
#' @return Called for its side effects; the value is not meaningful.
#' @examples
#' \dontrun{
#' PkgProjectBioconductor(path = getwd(), pkg = "stats")
#' }
#' @export
PkgProjectBioconductor <- function(path,
                                   pkg) {
  lib <- LibPaths(path = path)
  installed <- utils::installed.packages()
  pkg_installed <- installed[, "Package"]
  if (length(x = pkg) > 0) {
    for (i in seq_along(along.with = pkg)) {
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
