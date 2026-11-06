## ---- test-rProject-lint-r-named-args
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::test_that(
      paste(text, "flags what the rule forbids"),
      {
        root <- .TestLintProject(
          files = list("R/x.R" = c("y <- length(1)", "z <- stats::rnorm(1)"))
        )
        rows <- .LintRNamedArgs(path = root)
        testthat::expect_true(object = any(rows$rule == "named-args"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "passes what the rule allows"),
      {
        root <- .TestLintProject(
          files = list(
            "R/x.R" = c(
              "y <- length(x = 1)",
              "z <- paste(1, 2)",
              "w <- c(1, 2)",
              "a <- stats::rnorm(n = 1)"
            )
          )
        )
        rows <- .LintRNamedArgs(path = root)
        testthat::expect_false(object = any(rows$rule == "named-args"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-lint-r-named-args"
)
