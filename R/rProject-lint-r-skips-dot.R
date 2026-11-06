.LintRSkips <- function(path) {
  # no NOT_CRAN early-return block; packages have a smoke test
  level <- .LintLevel(path = path)
  tests <- .LintList(path = path, pattern = "^tests/testthat/[^/]+\\.[Rr]$")
  blocks <- lapply(
    X = tests,
    FUN = function(file) {
      # the string "NOT_CRAN" as code, so a test's own fixture does not count
      data <- .LintRParse(lines = .LintRead(path = path, file = file))
      hit <- integer(length = 0L)
      if (!is.null(x = data)) {
        hit <- data$line1[
          data$token == "STR_CONST" & data$text %in% c(
            "\"NOT_CRAN\"",
            "'NOT_CRAN'"
          )
        ]
      }
      if (length(x = hit) == 0L) {
        NULL
      } else {
        .LintRow(
          file = rep(x = file, times = length(x = hit)),
          line = hit,
          rule = "test-skips",
          message = "no NOT_CRAN block: use testthat::skip_on_cran()",
          level = level
        )
      }
    }
  )
  pkg <- .LintPkg(path = path)
  smoke <- file.path("tests", "testthat", paste0("test-", pkg, "-smoke.R"))
  missing_smoke <- NULL
  if (
    length(x = tests) > 0L &&
      file.exists(file.path(path, "DESCRIPTION")) &&
      !(smoke %in% tests)
  ) {
    missing_smoke <- .LintRow(
      file = smoke,
      line = 1L,
      rule = "test-skips",
      message = "add one fast smoke test file that runs on CRAN",
      level = level
    )
  }
  .LintBind(rows = c(blocks, list(missing_smoke)))
}
