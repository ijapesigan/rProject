.LibShadowed <- function(path,
                         lib_paths = .libPaths()) {
  # packages in .library that another library (the image) also has: a
  # copy from before rProject 0.0.57 that hides the image's version;
  # rProject and pak belong in .library
  lib <- normalizePath(
    path = file.path(path, ".library"),
    mustWork = FALSE
  )
  others <- setdiff(
    x = normalizePath(path = lib_paths, mustWork = FALSE),
    y = lib
  )
  packages <- function(libs) {
    # a package is a folder with a DESCRIPTION
    dirs <- list.dirs(path = libs, full.names = TRUE, recursive = FALSE)
    unique(
      x = basename(path = dirs[file.exists(file.path(dirs, "DESCRIPTION"))])
    )
  }
  mine <- packages(lib)
  theirs <- packages(others)
  out <- sort(
    x = setdiff(x = intersect(x = mine, y = theirs), y = c("rProject", "pak"))
  )
  if (length(x = out) > 0) {
    message(
      paste0(
        "\n\n.library has packages that the image also has: ",
        paste(out, collapse = ", "),
        ".\nThey hide the image's versions. Run make cleanpkg, ",
        "then make project.\n\n"
      )
    )
  }
  invisible(x = out)
}
