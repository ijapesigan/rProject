.LibShadowed <- function(path,
                         lib_paths = .libPaths()) {
  # packages in .library that another library (the image) also has: a
  # copy from before rProject 0.0.57 that hides the image's version;
  # rProject and pak belong in .library
  lib <- normalizePath(
    file.path(path, ".library"),
    mustWork = FALSE
  )
  others <- setdiff(normalizePath(lib_paths, mustWork = FALSE), lib)
  packages <- function(libs) {
    # a package is a folder with a DESCRIPTION
    dirs <- list.dirs(path = libs, full.names = TRUE, recursive = FALSE)
    unique(basename(dirs[file.exists(file.path(dirs, "DESCRIPTION"))]))
  }
  mine <- packages(lib)
  theirs <- packages(others)
  out <- sort(setdiff(intersect(mine, theirs), c("rProject", "pak")))
  if (length(out) > 0) {
    message(
      paste0(
        "\n\n.library has packages that the image also has: ",
        paste(out, collapse = ", "),
        ".\nThey hide the image's versions. Run make cleanpkg, ",
        "then make project.\n\n"
      )
    )
  }
  invisible(out)
}
