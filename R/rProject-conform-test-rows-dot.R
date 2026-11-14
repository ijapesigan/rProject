.ConformTestRows <- function(output,
                             status) {
  # the failures and errors (`Failure (test-x.R:3:5): description`) and the
  # counts (`[ FAIL 1 | WARN 0 | SKIP 2 | PASS 9 ]`) of `devtools::test()`
  output <- gsub(pattern = "\033\\[[0-9;]*m", replacement = "", x = output)
  hit <- regmatches(
    x = output,
    m = regexec(
      pattern = "^(Failure|Error) \\((\\S+?):([0-9]+):[0-9]+\\): ?(.*)$",
      text = output
    )
  )
  hit <- Filter(
    f = function(x) {
      length(x = x) == 5L
    },
    x = hit
  )
  rows <- lapply(
    X = hit,
    FUN = function(x) {
      .ConformRow(
        rule = "tests",
        class = "decide",
        file = paste0("tests/testthat/", x[[3]], ":", x[[4]]),
        message = paste0(tolower(x = x[[2]]), ": ", x[[5]])
      )
    }
  )
  summary <- grep(
    pattern = "^\\[ FAIL [0-9]+ \\| WARN [0-9]+ \\| SKIP [0-9]+ \\| PASS",
    x = output,
    value = TRUE
  )
  counts <- ifelse(
    test = length(x = summary) > 0L,
    yes = summary[[length(x = summary)]],
    no = "no summary line"
  )
  failed <- length(x = rows) > 0L || status != 0L ||
    grepl(pattern = "FAIL [1-9]", x = counts)
  rows <- c(
    list(
      .ConformRow(
        rule = "tests",
        class = ifelse(test = failed, yes = "decide", no = "info"),
        file = "devtools::test()",
        message = paste0("exit ", status, ", ", counts)
      )
    ),
    rows
  )
  .ConformBind(rows = rows)
}
