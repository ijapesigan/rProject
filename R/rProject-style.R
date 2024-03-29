#' Style Project
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @export
Style <- function(path) {
  lib <- LibPaths(path = path)
  installed <- utils::installed.packages()
  pkg_installed <- installed[, "Package"]
  if (!("styler" %in% pkg_installed)) {
    utils::install.packages(
      "styler",
      repos = c(REPO_NAME = PkgRepo(path = path)),
      lib = lib,
      quiet = TRUE
    )
  }
  styler::style_dir(
    path = path,
    exclude_dirs = c(
      ".library",
      file.path(
        ".setup",
        "notes"
      ),
      "renv",
      "packrat"
    )
  )
  find <- TRUE
  format <- TRUE
  if (Sys.which("find") == "") {
    find <- FALSE
  }
  if (Sys.which("clang-format") == "") {
    format <- FALSE
  }
  if (find == TRUE && format == TRUE) {
    system(
      paste0(
        "find",
        " ",
        "\"",
        file.path(path, ".setup", "cpp"),
        "\"",
        " ",
        "-name",
        " ",
        "\"",
        "*.cpp",
        "\"",
        " ",
        "! -name",
        " ",
        "\"",
        "RcppExports.cpp",
        "\"",
        " ",
        "-exec clang-format -style=google -i {} \\;"
      )
    )
    system(
      paste0(
        "find",
        " ",
        "\"",
        file.path(path, "src"),
        "\"",
        " ",
        "-name",
        " ",
        "\"",
        "*.cpp",
        "\"",
        " ",
        "! -name",
        " ",
        "\"",
        "RcppExports.cpp",
        "\"",
        " ",
        "-exec clang-format -style=google -i {} \\;"
      )
    )
  }
}
