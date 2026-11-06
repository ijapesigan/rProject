## ---- test-rProject-lint-r-exports
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::test_that(
      paste(text, "flags an export without docs or a test"),
      {
        root <- .TestLintProject(
          files = list(
            NAMESPACE = "export(FooBar)",
            "man/FooBar.Rd" = "\\alias{FooBar}"
          )
        )
        rows <- .LintRExports(path = root)
        testthat::expect_equal(object = nrow(x = rows), expected = 3L)
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "passes a documented and tested export"),
      {
        root <- .TestLintProject(
          files = list(
            NAMESPACE = "export(FooBar)",
            "man/FooBar.Rd" = c(
              "\\alias{FooBar}",
              "\\value{x}",
              "\\examples{x}"
            ),
            "tests/testthat/test-testProject-foo-bar.R" = "x <- 1"
          )
        )
        rows <- .LintRExports(path = root)
        testthat::expect_equal(object = nrow(x = rows), expected = 0L)
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-lint-r-exports"
)
