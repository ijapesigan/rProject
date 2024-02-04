#' Setup RStudio Package Manager Repository
#' Based on the Current Operating System
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @return Returns the repository url.
#' @export
PkgRepo <- function(path) {
  # source
  all <- "https://packagemanager.rstudio.com/all/"
  src <- paste0(
    all,
    "latest/"
  )
  repos <- src

  # set repos
  os <- .OS()
  if (os == "osx") {
    return(src)
  }
  if (os == "windows") {
    return(
      paste0(
        all,
        "latest/bin/windows"
      )
    )
  }
  if (os == "linux") {
    linux <- paste0(
      all,
      "__linux__/"
    )
    distro <- distro::distro()
    if (is.null(distro)) {
      return(src)
    } else {
      repos <- src
      if (tolower(distro$id) == "ubuntu") {
        if (distro$codename %in% c("bionic", "focal", "jammy")) {
          repos <- paste0(
            linux,
            distro$codename,
            "/latest"
          )
        }
      }
      if (tolower(distro$id) == "rocky") {
        if (distro$short_version == "9") {
          repos <- paste0(
            linux,
            "rhel9",
            "/latest"
          )
        }
        if (distro$short_version == "8") {
          repos <- paste0(
            linux,
            "centos8",
            "/latest"
          )
        }
      }
      # populate the rest of the available repositories
      return(repos)
    }
  }
}
