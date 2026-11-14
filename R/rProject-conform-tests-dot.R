.ConformTests <- function(path,
                          log_dir) {
  # `devtools::test()` with the same R (Rscript from R.home("bin")); the
  # counts are always reported, each failure or error is a row
  run <- .ConformCommand(
    command = file.path(R.home(component = "bin"), "Rscript"),
    args = c("-e", shQuote(string = "devtools::test()")),
    dir = path,
    env = c("NOT_CRAN=true", "NO_COLOR=1", "R_CLI_NUM_COLORS=0")
  )
  log <- file.path(log_dir, "conform-tests.log")
  writeLines(text = run$output, con = log)
  rows <- .ConformTestRows(output = run$output, status = run$status)
  attr(x = rows, which = "log") <- log
  rows
}
