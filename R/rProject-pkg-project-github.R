#' Install Project Packages from GitHub
#'
#' A package found in any library is never upgraded. It is installed when
#' it is missing, or when its `ref` is a commit SHA that differs from the
#' installed commit (`RemoteSha`). Dependencies are installed only when
#' missing.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @param pkg Character vector.
#'   GitHub packages.
#' @param ref Character vector.
#'   Git branch, tag, or commit SHA (only a SHA reinstalls).
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
    # a ref may also come with the package (owner/pkg@ref)
    at <- grepl("@", pkg)
    ref[at] <- sub("^[^@]*@", "", pkg[at])
    pkg <- sub("@.*$", "", pkg)
    for (i in seq_along(pkg)) {
      name <- basename(pkg[i])
      sha <- NA_character_
      if (name %in% pkg_installed) {
        sha <- suppressWarnings(
          utils::packageDescription(pkg = name, fields = "RemoteSha")
        )
      }
      run <- .PkgGitHubNeeded(
        installed = name %in% pkg_installed,
        ref = ref[i],
        sha = sha
      )
      if (run) {
        cat(
          paste0(
            "Installing ",
            pkg[i],
            " from GitHub...",
            "\n"
          )
        )
        # remotes sees every library in .libPaths(), so a dependency the
        # image has is neither reinstalled nor upgraded
        remotes::install_github(
          repo = paste0(
            pkg[i],
            "@",
            ref[i]
          ),
          lib = lib,
          upgrade = "never",
          repos = c(REPO_NAME = PkgRepo(path = path)),
          quiet = TRUE
        )
      }
    }
  }
}
