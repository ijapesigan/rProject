.DependenciesClean <- function(path) {
  # a helper renamed or deleted in functions must not stay in R/: delete the
  # copies of each helper set (<set>-*.R) before copying. functions has
  # folders named after packages, so a package's own files never count.
  sets <- list.dirs(
    path = file.path(path, ".setup", "r-dependencies"),
    full.names = FALSE,
    recursive = FALSE
  )
  package <- read.dcf(
    file = file.path(path, "DESCRIPTION"),
    fields = "Package"
  )
  stale <- lapply(
    X = setdiff(x = sets, y = package),
    FUN = function(set) {
      list.files(
        path = file.path(path, "R"),
        pattern = paste0("^", set, "-.*\\.R$"),
        full.names = TRUE
      )
    }
  )
  unlink(x = unlist(x = stale))
  invisible(x = NULL)
}
