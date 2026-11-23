.LinkedSources <- function(path) {
  # the pushed R/ of each library in .setup/r-dependencies/: the .verify
  # clone of the library project next to this one (<lib>, devel-<lib>, or
  # cran-<lib>); a library without one is left out (functions stands in)
  libs <- list.dirs(
    path = file.path(path, ".setup", "r-dependencies"),
    full.names = FALSE,
    recursive = FALSE
  )
  work <- dirname(path = normalizePath(path = path, mustWork = FALSE))
  sources <- vapply(
    X = libs,
    FUN = function(lib) {
      found <- file.path(
        work,
        c(lib, paste0("devel-", lib), paste0("cran-", lib)),
        ".verify",
        "R"
      )
      found <- found[dir.exists(paths = found)]
      if (length(x = found) == 0L) {
        NA_character_
      } else {
        found[1]
      }
    },
    FUN.VALUE = character(length = 1)
  )
  as.list(x = sources[!is.na(x = sources)])
}
