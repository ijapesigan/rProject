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
    run <- FALSE
    if (!(repo_pkg[i, "pkg"] %in% pkg_installed)) {
      run <- TRUE
    } else {
      if (is.null(utils::packageDescription(repo_pkg[i, "pkg"])$GithubRepo)) {
        run <- TRUE
      }
    }
    if (run) {
      cat(
        paste0(
          "Installing ",
          pkg[i],
          " from GitHub...",
          "\n"
        )
      )
      pak::pkg_install(
        pkg = pkg[i],
        lib = lib
      )
    }
  }
}
