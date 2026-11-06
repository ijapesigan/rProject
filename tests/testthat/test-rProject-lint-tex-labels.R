## ---- test-rProject-lint-tex-labels
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::test_that(
      paste(text, "flags what the rule forbids"),
      {
        root <- .TestLintProject(
          files = list(".setup/latex/a.tex" = c("\\label{sec:one}"))
        )
        rows <- .LintTexLabels(path = root)
        testthat::expect_true(object = any(rows$rule == "tex-label"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "passes what the rule allows"),
      {
        root <- .TestLintProject(
          files = list(".setup/latex/a.tex" = c("\\label{sec:testProject-one}"))
        )
        rows <- .LintTexLabels(path = root)
        testthat::expect_false(object = any(rows$rule == "tex-label"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-lint-tex-labels"
)
