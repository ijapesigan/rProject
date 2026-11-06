## ---- test-rProject-lint-md-fences
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::test_that(
      paste(text, "flags what the rule forbids"),
      {
        root <- .TestLintProject(
          files = list("b.md" = c("```", "x", "```"))
        )
        rows <- .LintMdFences(path = root)
        testthat::expect_true(object = any(rows$rule == "md-fence"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "passes what the rule allows"),
      {
        root <- .TestLintProject(
          files = list("b.md" = c("```r", "x", "```"))
        )
        rows <- .LintMdFences(path = root)
        testthat::expect_false(object = any(rows$rule == "md-fence"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-lint-md-fences"
)
