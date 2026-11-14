.ConformLint <- function(path,
                         log_dir) {
  # the real `make lint` (it runs `make style` first, so files may change:
  # read them again afterwards); never a re-implementation of its rules
  run <- .ConformCommand(
    command = "make",
    args = "lint",
    dir = path,
    env = c("NO_COLOR=1", "R_CLI_NUM_COLORS=0", "COLUMNS=10000")
  )
  log <- file.path(log_dir, "conform-lint.log")
  writeLines(text = run$output, con = log)
  rows <- .ConformLintRows(output = run$output, status = run$status)
  attr(x = rows, which = "log") <- log
  rows
}
