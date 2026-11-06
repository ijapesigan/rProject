## ---- test-rProject-lint-r-files
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::test_that(
      desc = paste(text, "flags what the rule forbids"),
      code = {
        root <- .TestLintProject(
          files = list("R/x.R" = c("y <- 1"))
        )
        rows <- .LintRFiles(path = root)
        testthat::expect_true(object = any(rows$rule == "file-name"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      desc = paste(text, "passes what the rule allows"),
      code = {
        root <- .TestLintProject(
          files = list("R/testProject-x.R" = c("y <- 1"))
        )
        rows <- .LintRFiles(path = root)
        testthat::expect_false(object = any(rows$rule == "file-name"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-lint-r-files"
)
