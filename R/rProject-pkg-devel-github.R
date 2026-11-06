#' Install Development Packages from GitHub
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @return Called for its side effects; the value is not meaningful.
#' @examples
#' \dontrun{
#' PkgDevelGitHub(path = getwd())
#' }
#' @export
PkgDevelGitHub <- function(path) {
  lib <- LibPaths(path = path)
  installed <- utils::installed.packages()
  pkg_installed <- installed[, "Package"]
  if (!("remotes" %in% pkg_installed)) {
    utils::install.packages(
      pkgs = "remotes",
      repos = c(REPO_NAME = PkgRepo(path = path)),
      lib = lib,
      quiet = TRUE
    )
  }
  pkg <- c(
    "rstudio/tinytex",
    "r-lib/cli",
    "r-lib/devtools"
  )
  repo_pkg <- strsplit(x = pkg, split = "/")
  repo_pkg <- do.call(
    what = "rbind",
    args = repo_pkg
  )
  colnames(x = repo_pkg) <- c("repo", "pkg")
  for (i in seq_along(along.with = pkg)) {
    # never upgrade: only a package missing from every library
    run <- !(repo_pkg[i, "pkg"] %in% pkg_installed)
    if (run) {
      cat(
        paste0(
          "Installing ",
          pkg[i],
          " from GitHub...",
          "\n"
        )
      )
      remotes::install_github(
        repo = pkg[i],
        lib = lib,
        upgrade = "never",
        repos = c(REPO_NAME = PkgRepo(path = path)),
        quiet = TRUE
      )
    }
  }
}
