## ---- test-rProject-lint-r-undesirable
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::test_that(
      paste(text, "flags what the rule forbids"),
      {
        root <- .TestLintProject(
          files = list("R/x.R" = c("library(stats)", "y <- 1 |> sum()"))
        )
        rows <- .LintRUndesirable(path = root)
        testthat::expect_true(object = any(rows$rule == "undesirable"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "passes what the rule allows"),
      {
        root <- .TestLintProject(
          files = list("R/x.R" = c("y <- sum(1)"))
        )
        rows <- .LintRUndesirable(path = root)
        testthat::expect_false(object = any(rows$rule == "undesirable"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-lint-r-undesirable"
)
