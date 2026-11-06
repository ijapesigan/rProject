.LintCppDeclarations <- function(path) {
  level <- .LintLevel(path = path)
  files <- .LintCppList(path = path)
  forward <- file.path(".setup", "cpp", "000-forward-declarations.cpp")
  if (length(x = files) == 0L) {
    .LintBind(rows = list())
  } else if (!(forward %in% files)) {
    .LintRow(
      file = forward,
      line = 1L,
      rule = "cpp-declarations",
      message = "add the forward declarations file",
      level = level
    )
  } else {
    declared <- .LintCppFunctions(
      lines = .LintRead(path = path, file = forward),
      end = ";"
    )$name
    .LintBind(
      rows = lapply(
        X = setdiff(x = files, y = forward),
        FUN = function(file) {
          found <- .LintCppFunctions(
            lines = .LintRead(path = path, file = file)
          )
          found <- found[!(found$name %in% declared), , drop = FALSE]
          .LintRow(
            file = rep(x = file, times = nrow(x = found)),
            line = found$line,
            rule = "cpp-declarations",
            message = paste0(
              found$name,
              " is not in 000-forward-declarations.cpp"
            ),
            level = level
          )
        }
      )
    )
  }
}
