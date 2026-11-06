## ---- test-rProject-lint-r-namespace
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::test_that(
      desc = paste(text, "flags what the rule forbids"),
      code = {
        root <- .TestLintProject(
          files = list("R/x.R" = c("y <- rnorm(n = 1)"))
        )
        rows <- .LintRNamespace(path = root)
        testthat::expect_true(object = any(rows$rule == "namespace"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      desc = paste(text, "passes what the rule allows"),
      code = {
        root <- .TestLintProject(
          files = list(
            "R/x.R" = c(
              "rnorm <- function(n) {",
              "  n",
              "}",
              "y <- stats::rnorm(n = 1)",
              "z <- length(x = y)"
            )
          )
        )
        rows <- .LintRNamespace(path = root)
        testthat::expect_false(object = any(rows$rule == "namespace"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-lint-r-namespace"
)
