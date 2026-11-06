## ---- test-rProject-lint-md-headings
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::test_that(
      desc = paste(text, "flags what the rule forbids"),
      code = {
        root <- .TestLintProject(
          files = list(
            "b.md" = c("# T", "", "# U", "", "### V", "", "W", "===")
          )
        )
        rows <- .LintMdHeadings(path = root)
        testthat::expect_true(object = any(rows$rule == "md-heading"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      desc = paste(text, "passes what the rule allows"),
      code = {
        root <- .TestLintProject(
          files = list("b.md" = c("# T", "", "## U"))
        )
        rows <- .LintMdHeadings(path = root)
        testthat::expect_false(object = any(rows$rule == "md-heading"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-lint-md-headings"
)
