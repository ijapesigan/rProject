.LintRExports <- function(path) {
  # each export has an .Rd with \value and \examples, and a test file
  level <- .LintLevel(path = path)
  namespace <- file.path(path, "NAMESPACE")
  if (!file.exists(namespace)) {
    .LintBind(rows = list())
  } else {
    pkg <- .LintPkg(path = path)
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
    rd_files <- list.files(
      path = file.path(path, "man"),
      pattern = "\\.Rd$",
      full.names = TRUE
    )
    rd <- lapply(X = rd_files, FUN = readLines, warn = FALSE)
    rows <- lapply(
      X = exports,
      FUN = function(name) {
        alias <- paste0("\\alias{", name, "}")
        hit <- vapply(
          X = rd,
          FUN = function(lines) {
            alias %in% lines
          },
          FUN.VALUE = logical(length = 1)
        )
        text <- unlist(x = rd[hit])
        problems <- c(
          if (!any(startsWith(x = text, prefix = "\\value"))) {
            "no @return"
          },
          if (!any(startsWith(x = text, prefix = "\\examples"))) {
            "no @examples"
          },
          if (
            !file.exists(
              file.path(
                path,
                "tests",
                "testthat",
                paste0("test-", pkg, "-", .LintKebab(x = name), ".R")
              )
            )
          ) {
            paste0("no test-", pkg, "-", .LintKebab(x = name), ".R")
          }
        )
        if (length(x = problems) == 0L) {
          NULL
        } else {
          .LintRow(
            file = rep(x = "NAMESPACE", times = length(x = problems)),
            line = rep(x = 1L, times = length(x = problems)),
            rule = "exports",
            message = paste0(name, "(): ", problems),
            level = level
          )
        }
      }
    )
    .LintBind(rows = rows)
  }
}
