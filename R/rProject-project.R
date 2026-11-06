#' Setup the project.Rproj file
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @return Called for its side effects; the value is not meaningful.
#' @examples
#' \dontrun{
#' Project(path = getwd())
#' }
#' @export
Project <- function(path) {
  lib <- LibPaths(path = path)
  installed <- utils::installed.packages()
  pkg_installed <- installed[, "Package"]
  if (!("rprojroot" %in% pkg_installed)) {
    utils::install.packages(
      pkgs = "rprojroot",
      repos = c(REPO_NAME = PkgRepo(path = path)),
      lib = lib,
      quiet = TRUE
    )
  }
  x <- paste0(
    "Version: 1.0", "\n",
    "\n",
    "RestoreWorkspace: Default", "\n",
    "SaveWorkspace: Default", "\n",
    "AlwaysSaveHistory: Default", "\n",
    "\n",
    "EnableCodeIndexing: Yes", "\n",
    "UseSpacesForTab: Yes", "\n",
    "NumSpacesForTab: 2", "\n",
    "Encoding: UTF-8", "\n",
    "\n",
    "RnwWeave: Sweave", "\n",
    "LaTeX: pdfLaTeX", "\n",
    "\n",
    "AutoAppendNewline: Yes", "\n",
    "StripTrailingWhitespace: Yes", "\n",
    "\n",
    "BuildType: Package", "\n",
    "PackageUseDevtools: Yes", "\n",
    "PackageInstallArgs: --no-multiarch --with-keep.source", "\n",
    "PackageRoxygenize: rd,collate,namespace", "\n"
  )
  con <- file(
    description = file.path(
      path,
      "project.Rproj"
    )
  )
  writeLines(
    text = x,
    con = con
  )
  close(con = con)
  # where the project lives (private GitHub, Overleaf, public GitHub)
  .RepoInfoWrite(path = path)
  # packages in .library that hide the image's (rProject 0.0.57)
  .LibShadowed(path = path)
  root <- rprojroot::is_rstudio_project
  cat(
    paste(
      "Project directory:",
      dirname(
        path = root$find_file(
          "project.Rproj"
        )
      ),
      "\n"
    )
  )
}
# see https://github.com/r-lib/devtools/blob/main/devtools.Rproj
