## ---- test-rProject-lint-md-bullets
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::test_that(
      desc = paste(text, "flags what the rule forbids"),
      code = {
        root <- .TestLintProject(
          files = list("b.md" = c("# T", "", "* a"))
        )
        rows <- .LintMdBullets(path = root)
        testthat::expect_true(object = any(rows$rule == "md-bullet"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      desc = paste(text, "passes what the rule allows"),
      code = {
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
