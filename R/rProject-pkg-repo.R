#' Setup RStudio Package Manager Repository
#' Based on the Current Operating System
#'
#' The repository is the Posit Package Manager snapshot of the image's
#' date, so that a package the image lacks matches the image's other
#' packages: the environment variable `RPROJECT_SNAPSHOT` (set in GitHub
#' Actions from the lock), the date of the running sif, the lock's
#' `snapshot`, or `latest`.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @return Returns the repository url.
#' @export
PkgRepo <- function(path) {
  # source
  # the cran repository: the all repository (CRAN and Bioconductor) no
  # longer serves date snapshots
  ppm <- "https://packagemanager.posit.co/cran/"
  snapshot <- .PkgSnapshot(path = path)
  src <- paste0(
    ppm,
    snapshot,
    "/"
  )
  repos <- src

  # set repos
  os <- .OS()
  if (os == "osx") {
    # nolint start
    return(src)
    # nolint end
  }
  if (os == "windows") {
    # nolint start
    return(
      paste0(
        ppm,
        snapshot,
        "/bin/windows"
      )
    )
    # nolint end
  }
  if (os == "linux") {
    linux <- paste0(
      ppm,
      "__linux__/"
    )
    distro <- distro::distro()
    if (is.null(distro)) {
      # nolint start
      return(src)
      # nolint end
    } else {
      repos <- src
      if (tolower(distro$id) == "ubuntu") {
        if (distro$codename %in% c("bionic", "focal", "jammy", "noble")) {
          repos <- paste0(
            linux,
            distro$codename,
            "/",
            snapshot
          )
        }
      }
      if (tolower(distro$id) == "rocky") {
        if (distro$short_version == "9") {
          repos <- paste0(
            linux,
            "rhel9",
            "/",
            snapshot
          )
        }
        if (distro$short_version == "8") {
          repos <- paste0(
            linux,
            "centos8",
            "/",
            snapshot
          )
        }
      }
      # populate the rest of the available repositories
      # nolint start
      return(repos)
      # nolint end
    }
  }
}
