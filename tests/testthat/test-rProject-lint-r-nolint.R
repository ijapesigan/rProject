## ---- test-rProject-lint-r-nolint
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::test_that(
      paste(text, "flags what the rule forbids"),
      {
        root <- .TestLintProject(
          files = list("R/x.R" = c("x <- 1 # nolint"))
        )
        rows <- .LintRNolint(path = root)
        testthat::expect_true(object = any(rows$rule == "nolint"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "passes what the rule allows"),
      {
        root <- .TestLintProject(
          files = list("R/x.R" = c("x <- 1"))
        )
        rows <- .LintRNolint(path = root)
        testthat::expect_false(object = any(rows$rule == "nolint"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-lint-r-nolint"
)
