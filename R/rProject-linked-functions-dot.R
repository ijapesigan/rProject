.LinkedFunctions <- function(path,
                             functions = NULL) {
  # the local clone of the functions repository: the argument, else
  # .setup/repo/functions.md (one line, a path), else next to the project
  if (is.null(x = functions)) {
    file <- file.path(path, ".setup", "repo", "functions.md")
    recorded <- character(length = 0)
    if (file.exists(file)) {
      recorded <- trimws(x = readLines(con = file, warn = FALSE))
      recorded <- recorded[nzchar(x = recorded)]
    }
    functions <- c(
      recorded,
      file.path(
        dirname(path = normalizePath(path = path, mustWork = FALSE)),
        "functions"
      )
    )[1]
  }
  functions
}
