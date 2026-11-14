.ConformLintRows <- function(output,
                             status) {
  # the findings of `make lint` from its output: the lintr messages
  # (`file:line:col: style: [linter] message`) and the rows of the house
  # table (`file line rule message level`); a failing run with no row yields
  # one row
  output <- gsub(pattern = "\033\\[[0-9;]*m", replacement = "", x = output)
  lintr <- regmatches(
    x = output,
    m = regexec(
      pattern = "^(\\S+?):([0-9]+):[0-9]+: (style|warning|error): (.*)$",
      text = output
    )
  )
  lintr <- Filter(
    f = function(x) {
      length(x = x) == 5L
    },
    x = lintr
  )
  rows <- lapply(
    X = lintr,
    FUN = function(x) {
      .ConformRow(
        rule = "lint",
        class = "decide",
        file = paste0(x[[2]], ":", x[[3]]),
        message = paste0(x[[4]], ": ", x[[5]])
      )
    }
  )
  rows <- c(rows, .ConformHouseRows(output = output))
  if (length(x = rows) == 0L && status != 0L) {
    rows <- list(
      .ConformRow(
        rule = "lint",
        class = "decide",
        file = "make lint",
        message = paste0("failed (exit ", status, ") with no parsable row")
      )
    )
  }
  .ConformBind(rows = rows)
}
