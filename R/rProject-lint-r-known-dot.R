.LintRKnown <- function(path) {
  # the functions a project can see: exports of the default packages,
  # testthat, and DESCRIPTION's packages; base, and the project's own
  pkgs <- c("stats", "utils", "methods", "graphics", "grDevices", "testthat")
  description <- file.path(path, "DESCRIPTION")
  if (file.exists(description)) {
    fields <- read.dcf(
      file = description,
      fields = c("Depends", "Imports", "Suggests")
    )
    listed <- unlist(
      x = strsplit(x = fields[!is.na(x = fields)], split = ",")
    )
    pkgs <- c(
      pkgs,
      trimws(x = sub(pattern = "\\(.*$", replacement = "", x = listed))
    )
  }
  pkgs <- setdiff(x = unique(x = pkgs), y = c("R", "base"))
  pkgs <- pkgs[
    vapply(
      X = pkgs,
      FUN = requireNamespace,
      FUN.VALUE = logical(length = 1),
      quietly = TRUE
    )
  ]
  exports <- lapply(X = pkgs, FUN = getNamespaceExports)
  list(
    base = ls(envir = baseenv(), all.names = TRUE),
    pkg = stats::setNames(
      object = rep(x = pkgs, times = lengths(x = exports)),
      nm = unlist(x = exports)
    ),
    local = .LintRLocal(path = path)
  )
}
