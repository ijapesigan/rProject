## ---- test-rProject-lint-r-nolint
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::test_that(
      desc = paste(text, "flags what the rule forbids"),
      code = {
        root <- .TestLintProject(
          files = list("R/x.R" = c("x <- 1 # nolint"))
        )
        rows <- .LintRNolint(path = root)
        testthat::expect_true(object = any(rows$rule == "nolint"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      desc = paste(text, "passes what the rule allows"),
      code = {
        root <- .TestLintProject(
          files = list("R/x.R" = c("x <- 1"))
        )
        rows <- .LintRNolint(path = root)
        testthat::expect_false(object = any(rows$rule == "nolint"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      desc = paste(text, "flags a block start without a reason"),
      code = {
        root <- .TestLintProject(
          files = list(
            "R/x.R" = c(
              "# nolint start: object_name_linter.",
              "x <- 1",
              "# nolint end"
            )
          )
        )
        rows <- .LintRNolint(path = root)
        testthat::expect_equal(
          object = rows$line[rows$level != "note"],
          expected = 1L
        )
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      desc = paste(text, "notes a block with a reason; skips its end"),
      code = {
        root <- .TestLintProject(
          files = list(
            "R/x.R" = c(
              "# nolint start: object_name_linter. Reason: OpenMx names.",
              "x <- 1",
              "# nolint end"
            )
          )
        )
        rows <- .LintRNolint(path = root)
        testthat::expect_equal(object = rows$level, expected = "note")
        testthat::expect_equal(object = rows$line, expected = 1L)
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-lint-r-nolint"
)
