#' Install Project Packages with Specific Version
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @param pkg Character vector.
#'   R packages.
#' @param ver Character vector.
#'   Version.
#' @return Called for its side effects; the value is not meaningful.
#' @examples
#' \dontrun{
#' PkgProjectVersion(path = getwd(), pkg = "stats", ver = "1.0.0")
#' }
#' @export
PkgProjectVersion <- function(path,
                              pkg,
                              ver) {
  PkgProject(
    path = path,
    pkg = pkg
  )
  if (length(x = pkg) > 0) {
    stopifnot(length(x = pkg) == length(x = ver))
    lib <- LibPaths(path = path)
    installed <- utils::installed.packages()
    pkg_installed <- installed[, "Package"]
    repos <- c(REPO_NAME = PkgRepo(path = path))
    if (!("remotes" %in% pkg_installed)) {
      utils::install.packages(
        pkgs = "remotes",
        repos = repos,
        lib = lib,
        quiet = TRUE
      )
    }
    for (i in seq_along(along.with = pkg)) {
      pkg_i <- installed[pkg[i], ]
      ver_i <- pkg_i[["Version"]]
      if (ver_i != ver[i]) {
        cat(
          paste0(
            "Installing ",
            pkg[i],
            " ",
            ver[i],
            "...",
            "\n"
          )
        )
        remotes::install_version(
          package = pkg[i],
          version = ver[i],
          repos = repos,
          lib = lib,
          upgrade = "never",
          quiet = TRUE
        )
      }
    }
  }
}
