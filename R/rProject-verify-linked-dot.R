.VerifyLinked <- function(path,
                          private) {
  # a note, not a failure: a project may lag functions between pushes
  functions <- .LinkedFunctions(path = path)
  status <- .LinkedStatus(path = private, functions = functions)
  if (nrow(x = status) == 0L) {
    c(status = "pass", detail = "none")
  } else if (!dir.exists(paths = functions)) {
    c(
      status = "pass",
      detail = paste("not checked: no functions clone at", functions)
    )
  } else {
    bad <- status$status != "same"
    if (any(bad)) {
      c(
        status = "warn",
        detail = paste0(
          "links to refresh: ",
          paste0(
            status$file[bad],
            " (",
            status$status[bad],
            ")",
            collapse = "; "
          )
        )
      )
    } else {
      c(
        status = "pass",
        detail = paste(nrow(x = status), "files same as functions")
      )
    }
  }
}
