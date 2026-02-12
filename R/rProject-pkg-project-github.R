#' Install Project Packages from GitHub
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @param pkg Character vector.
#'   GitHub packages.
#' @param ref Character vector.
#'   Git branch.
#' @export
PkgProjectGitHub <- function(path,
                             pkg,
                             ref = "HEAD") {
  if (length(pkg) > 0) {
    lib <- LibPaths(path = path)
    if (length(ref) == 1) {
      if (ref == "HEAD") {
        ref <- rep(
          x = ref,
          times = length(pkg)
        )
      }
    }
    stopifnot(
      length(pkg) == length(ref)
    )
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
    repo_pkg <- strsplit(pkg, split = "/")
    repo_pkg <- do.call(
      what = "rbind",
      args = repo_pkg
    )
    colnames(repo_pkg) <- c("repo", "pkg")
    for (i in seq_along(pkg)) {
      run <- FALSE
      if (grepl("@", repo_pkg[i, "pkg"])) {
        run <- TRUE
      } else {
        if (!(repo_pkg[i, "pkg"] %in% pkg_installed)) {
          run <- TRUE
        } else {
          if (
            is.null(
              utils::packageDescription(
                repo_pkg[i, "pkg"]
              )$GithubRepo
            )
          ) {
            run <- TRUE
          }
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
        pak::pak(
          pkg = paste0(
            pkg[i],
            "@",
            ref[i]
          ),
          lib = lib
        )
      }
    }
  }
}
