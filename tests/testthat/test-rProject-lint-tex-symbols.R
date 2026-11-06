## ---- test-rProject-lint-tex-symbols
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::test_that(
      desc = paste(text, "flags what the rule forbids"),
      code = {
        root <- .TestLintProject(
          files = list(".setup/latex/a.tex" = c("$x^{\\top}$"))
        )
        rows <- .LintTexSymbols(path = root)
        testthat::expect_true(object = any(rows$rule == "tex-symbol"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      desc = paste(text, "passes what the rule allows"),
      code = {
        root <- .TestLintProject(
          files = list(".setup/latex/a.tex" = c("$\\boldsymbol{x}^{\\prime}$"))
        )
        rows <- .LintTexSymbols(path = root)
        testthat::expect_false(object = any(rows$rule == "tex-symbol"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-lint-tex-symbols"
)
