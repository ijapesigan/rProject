## ---- test-rProject-lint-md-fences
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::test_that(
      desc = paste(text, "flags what the rule forbids"),
      code = {
        root <- .TestLintProject(
          files = list("b.md" = c("```", "x", "```"))
        )
        rows <- .LintMdFences(path = root)
        testthat::expect_true(object = any(rows$rule == "md-fence"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      desc = paste(text, "passes what the rule allows"),
      code = {
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
