## ---- test-rProject-lint-md-bullets
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::test_that(
      paste(text, "flags what the rule forbids"),
      {
        root <- .TestLintProject(
          files = list("b.md" = c("# T", "", "* a"))
        )
        rows <- .LintMdBullets(path = root)
        testthat::expect_true(object = any(rows$rule == "md-bullet"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "passes what the rule allows"),
      {
        root <- .TestLintProject(
          files = list("b.md" = c("# T", "", "- a", "", "```r", "* 2", "```"))
        )
        rows <- .LintMdBullets(path = root)
        testthat::expect_false(object = any(rows$rule == "md-bullet"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-lint-md-bullets"
)
