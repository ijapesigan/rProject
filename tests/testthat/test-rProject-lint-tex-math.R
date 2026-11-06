## ---- test-rProject-lint-tex-math
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::test_that(
      paste(text, "flags what the rule forbids"),
      {
        root <- .TestLintProject(
          files = list("R/testProject-x.R" = c("#' \\eqn{\\Beta}"))
        )
        rows <- .LintTexMath(path = root)
        testthat::expect_true(object = any(rows$rule == "tex-math"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "passes what the rule allows"),
      {
        root <- .TestLintProject(
          files = list("R/testProject-x.R" = c("#' \\eqn{\\mathrm{B}}"))
        )
        rows <- .LintTexMath(path = root)
        testthat::expect_false(object = any(rows$rule == "tex-math"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-lint-tex-math"
)
