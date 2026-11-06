## ---- test-rProject-lint-tex-numbers
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::test_that(
      desc = paste(text, "flags what the rule forbids"),
      code = {
        root <- .TestLintProject(
          files = list(".setup/latex/a.tex" = c("See Equation 3."))
        )
        rows <- .LintTexNumbers(path = root)
        testthat::expect_true(object = any(rows$rule == "tex-number"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      desc = paste(text, "passes what the rule allows"),
      code = {
        root <- .TestLintProject(
          files = list(".setup/latex/a.tex" = c("See Equation~\\ref{a}."))
        )
        rows <- .LintTexNumbers(path = root)
        testthat::expect_false(object = any(rows$rule == "tex-number"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-lint-tex-numbers"
)
