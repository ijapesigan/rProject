#' Style Project
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @return Called for its side effects; the value is not meaningful.
#' @examples
#' \dontrun{
#' Style(path = getwd())
#' }
#' @export
Style <- function(path) {
  lib <- LibPaths(path = path)
  installed <- utils::installed.packages()
  pkg_installed <- installed[, "Package"]
  if (!("styler" %in% pkg_installed)) {
    utils::install.packages(
      pkgs = "styler",
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
  if (Sys.which(names = "clang-format") != "") {
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
    cpp <- cpp[basename(path = cpp) != "RcppExports.cpp"]
    if (length(x = cpp) > 0) {
      system2(
        command = "clang-format",
        args = c(
          .LintCppStyle(),
          "-i",
          .ShellQuote(x = cpp)
        )
      )
    }
  }
}
