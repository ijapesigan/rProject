## ---- test-rProject-lint-r-skips
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::test_that(
      paste(text, "flags what the rule forbids"),
      {
        root <- .TestLintProject(
          files = list(
            "tests/testthat/test-testProject-a.R" = c(
              "if (!identical(Sys.getenv(\"NOT_CRAN\"), \"true\")) {",
              "}"
            )
          )
        )
        rows <- .LintRSkips(path = root)
        testthat::expect_true(object = any(rows$rule == "test-skips"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "passes what the rule allows"),
      {
        root <- .TestLintProject(
          files = list("tests/testthat/test-testProject-smoke.R" = c("x <- 1"))
        )
        rows <- .LintRSkips(path = root)
        testthat::expect_false(object = any(rows$rule == "test-skips"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-lint-r-skips"
)
