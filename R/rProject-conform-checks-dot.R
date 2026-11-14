.ConformChecks <- function(path,
                           lint,
                           tests,
                           log_dir) {
  # the real `make lint` and the unit tests, as findings; `logs` names the
  # raw outputs
  parts <- list()
  if (lint) {
    parts$lint <- .ConformLint(path = path, log_dir = log_dir)
  }
  if (tests) {
    parts$tests <- .ConformTests(path = path, log_dir = log_dir)
  }
  rows <- .ConformBind(rows = unname(obj = parts))
  attr(x = rows, which = "logs") <- vapply(
    X = parts,
    FUN = function(x) {
      attr(x = x, which = "log")
    },
    FUN.VALUE = character(length = 1)
  )
  rows
}
