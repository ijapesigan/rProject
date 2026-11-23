.VerifyLinked <- function(path,
                          private) {
  # a note, not a failure: a project may lag a library between pushes. The
  # source is each library's pushed state (its .verify clone), else the
  # functions clone
  functions <- .LinkedFunctions(path = path)
  sources <- .LinkedSources(path = path)
  status <- .LinkedStatus(
    path = private,
    functions = functions,
    sources = sources
  )
  lib <- vapply(
    X = strsplit(x = status$file, split = "/", fixed = TRUE),
    FUN = function(x) {
      x[1]
    },
    FUN.VALUE = character(length = 1)
  )
  unchecked <- !(lib %in% names(x = sources)) & !dir.exists(paths = functions)
  status <- status[!unchecked, , drop = FALSE]
  note <- if (any(unchecked)) {
    paste0(
      "; not checked (no .verify clone, no functions clone): ",
      paste(unique(x = lib[unchecked]), collapse = ", ")
    )
  } else {
    ""
  }
  if (nrow(x = status) == 0L) {
    c(
      status = "pass",
      detail = paste0(
        if (any(unchecked)) {
          "none checked"
        } else {
          "none"
        },
        note
      )
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
          ),
          note
        )
      )
    } else {
      c(
        status = "pass",
        detail = paste0(
          nrow(x = status),
          " files same as the pushed libraries",
          note
        )
      )
    }
  }
}
