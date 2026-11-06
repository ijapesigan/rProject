## ---- test-rProject-lint-r-undesirable
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::test_that(
      desc = paste(text, "flags what the rule forbids"),
      code = {
        root <- .TestLintProject(
          files = list("R/x.R" = c("library(stats)", "y <- 1 |> sum()"))
        )
        rows <- .LintRUndesirable(path = root)
        testthat::expect_true(object = any(rows$rule == "undesirable"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      desc = paste(text, "passes what the rule allows"),
      code = {
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
