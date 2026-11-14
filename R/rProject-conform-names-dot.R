.ConformNames <- function(path) {
  # each export has a test file test-<pkg>-<kebab-name>.R (the rule of
  # make lint, through .LintKebab()); operators are skipped
  namespace <- file.path(path, "NAMESPACE")
  exports <- character(length = 0)
  if (file.exists(namespace)) {
    exports <- grep(
      pattern = "^export\\(",
      x = readLines(con = namespace, warn = FALSE),
      value = TRUE
    )
    exports <- gsub(
      pattern = "^export\\(\\\"?|\\\"?\\)$",
      replacement = "",
      x = exports
    )
    exports <- exports[make.names(names = exports) == exports]
  }
  if (length(x = exports) > 0L) {
    tests <- file.path(
      "tests",
      "testthat",
      paste0("test-", .LintPkg(path = path), "-", .LintKebab(x = exports), ".R")
    )
    missing <- !file.exists(file.path(path, tests))
    .ConformRow(
      rule = "test-name",
      class = "decide",
      file = tests[missing],
      message = paste0(
        exports[missing],
        "(): no ",
        basename(path = tests[missing])
      )
    )
  } else {
    .ConformEmpty()
  }
}
