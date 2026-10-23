#' Install Development Packages from GitHub
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @export
PkgDevelGitHub <- function(path) {
  lib <- LibPaths(path = path)
  installed <- utils::installed.packages()
  pkg_installed <- installed[, "Package"]
  if (!("remotes" %in% pkg_installed)) {
    utils::install.packages(
      "remotes",
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
  repo_pkg <- strsplit(pkg, split = "/")
  repo_pkg <- do.call(
    what = "rbind",
    args = repo_pkg
  )
  colnames(repo_pkg) <- c("repo", "pkg")
  for (i in seq_along(pkg)) {
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
