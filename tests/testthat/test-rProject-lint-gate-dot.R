## ---- test-rProject-lint-gate-dot
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    fake <- function(linter) {
      lint <- lintr::Lint(
        filename = "R/a.R",
        line_number = 3L,
        column_number = 1L,
        type = "style",
        message = "Lines should not be more than 80 characters.",
        line = "x"
      )
      lint$linter <- linter
      structure(
        .Data = list(lint),
        class = "lints"
      )
    }
    testthat::test_that(
      desc = paste(text, "stops on a line length finding in a package"),
      code = {
        withr::local_envvar(.new = c(LINTR_ERROR_ON_LINT = NA))
        utils::capture.output(
          testthat::expect_error(
            object = .LintGate(
              lints = fake(linter = "line_length_linter"),
              type = "cran"
            ),
            regexp = "R/a.R:3"
          )
        )
        utils::capture.output(
          testthat::expect_error(
            object = .LintGate(
              lints = fake(linter = "line_length_linter"),
              type = "rProject"
            ),
            regexp = "over 80 characters"
          )
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "passes other findings, other types, and the switch"),
      code = {
        withr::local_envvar(.new = c(LINTR_ERROR_ON_LINT = NA))
        testthat::expect_silent(
          object = .LintGate(
            lints = fake(linter = "object_usage_linter"),
            type = "cran"
          )
        )
        testthat::expect_silent(
          object = .LintGate(
            lints = fake(linter = "line_length_linter"),
            type = "man"
          )
        )
        withr::local_envvar(.new = c(LINTR_ERROR_ON_LINT = "false"))
        testthat::expect_silent(
          object = .LintGate(
            lints = fake(linter = "line_length_linter"),
            type = "cran"
          )
        )
      }
    )
  },
  text = "test-rProject-lint-gate-dot"
)
