## ---- test-rProject-smoke
# The one test file that runs on CRAN: fast, no network, no container.
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::test_that(
      paste(text, "the package loads and a check runs"),
      {
        testthat::expect_true(
          object = requireNamespace(package = "rProject", quietly = TRUE)
        )
        testthat::expect_identical(
          object = .LintKebab(x = "AIGlobal"),
          expected = "ai-global"
        )
      }
    )
  },
  text = "test-rProject-smoke"
)
