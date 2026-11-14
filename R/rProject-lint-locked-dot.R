.LintLocked <- function(path,
                        files) {
  # TRUE for the files that are locked copies of another library: files that
  # make copies from .setup/r-dependencies/<lib>/ and .setup/cpp/<lib>/, and
  # files named <lib>-<name> for a <lib> folder declared there
  libs <- unique(
    x = c(
      list.dirs(
        path = file.path(path, ".setup", "r-dependencies"),
        full.names = FALSE,
        recursive = FALSE
      ),
      list.dirs(
        path = file.path(path, ".setup", "cpp"),
        full.names = FALSE,
        recursive = FALSE
      )
    )
  )
  libs <- libs[nzchar(x = libs)]
  by_name <- vapply(
    X = basename(path = files),
    FUN = function(file) {
      any(startsWith(x = file, prefix = paste0(libs, "-")))
    },
    FUN.VALUE = logical(length = 1)
  )
  unname(obj = files %in% .ConformLocked(path = path) | by_name)
}
