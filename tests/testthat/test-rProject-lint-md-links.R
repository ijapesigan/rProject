## ---- test-rProject-lint-md-links
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::test_that(
      paste(text, "flags what the rule forbids"),
      {
        root <- .TestLintProject(
          files = list("b.md" = c("see https://a.b and [here](https://a.b)"))
        )
        rows <- .LintMdLinks(path = root)
        testthat::expect_true(object = any(rows$rule == "md-link"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "passes what the rule allows"),
      {
        root <- .TestLintProject(
          files = list(
            "b.md" = c("see <https://a.b> and [the page](https://a.b)")
          )
        )
        rows <- .LintMdLinks(path = root)
        testthat::expect_false(object = any(rows$rule == "md-link"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-lint-md-links"
)
