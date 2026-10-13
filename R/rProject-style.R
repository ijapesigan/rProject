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
      ".verify",
      file.path(
        ".setup",
        "notes"
      ),
      "renv",
      "packrat"
    )
  )
  # C++ in .setup/cpp and src, except the generated RcppExports.cpp
  if (Sys.which("clang-format") != "") {
    cpp <- list.files(
      path = file.path(
        path,
        c(
          file.path(
            ".setup",
            "cpp"
          ),
          "src"
        )
      ),
      pattern = "\\.cpp$",
      full.names = TRUE,
      recursive = TRUE
    )
    cpp <- cpp[basename(cpp) != "RcppExports.cpp"]
    if (length(cpp) > 0) {
      system2(
        command = "clang-format",
        args = c(
          "-style=google",
          "-i",
          .ShellQuote(x = cpp)
        )
      )
    }
  }
}
