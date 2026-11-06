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
#' @return Called for its side effects; the value is not meaningful.
#' @examples
#' \dontrun{
#' PkgProjectGitHub(path = getwd(), pkg = "stats")
#' }
#' @export
PkgProjectGitHub <- function(path,
                             pkg,
                             ref = "HEAD") {
  if (length(x = pkg) > 0) {
    lib <- LibPaths(path = path)
    if (length(x = ref) == 1) {
      if (ref == "HEAD") {
        ref <- rep(
          x = ref,
          times = length(x = pkg)
        )
      }
    }
    stopifnot(
      length(x = pkg) == length(x = ref)
    )
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
    # a ref may also come with the package (owner/pkg@ref)
    at <- grepl(pattern = "@", x = pkg)
    ref[at] <- sub(pattern = "^[^@]*@", replacement = "", x = pkg[at])
    pkg <- sub(pattern = "@.*$", replacement = "", x = pkg)
    for (i in seq_along(along.with = pkg)) {
      name <- basename(path = pkg[i])
      sha <- NA_character_
      if (name %in% pkg_installed) {
        sha <- suppressWarnings(
          expr = utils::packageDescription(pkg = name, fields = "RemoteSha")
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
