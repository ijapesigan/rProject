## ---- test-rProject-lint-r-named-args
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::test_that(
      desc = paste(text, "flags what the rule forbids"),
      code = {
        root <- .TestLintProject(
          files = list("R/x.R" = c("y <- length(1)", "z <- stats::rnorm(1)"))
        )
        rows <- .LintRNamedArgs(path = root)
        testthat::expect_true(object = any(rows$rule == "named-args"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      desc = paste(text, "passes what the rule allows"),
      code = {
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
    testthat::test_that(
      desc = paste(text, "does not count a forwarded dots as positional"),
      code = {
        root <- .TestLintProject(
          files = list(
            "R/x.R" = c(
              "f <- function(x, y, ...) {",
              "  x",
              "}",
              "g <- function(...) {",
              "  f(x = 1, ...)",
              "}"
            )
          )
        )
        rows <- .LintRNamedArgs(path = root)
        testthat::expect_false(object = any(rows$rule == "named-args"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      desc = paste(text, "does not count forwarded dots of a call to another file"),
      code = {
        root <- .TestLintProject(
          files = list(
            "R/x.R" = c(
              "f <- function(x, y = 1, z = 2, ...) {",
              "  x",
              "}"
            ),
            "R/y.R" = c(
              "g <- function(...) {",
              "  f(x = 1, ...)",
              "}",
              "h <- function(...) {",
              "  f(x = 1, y = 3, ..1)",
              "}"
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
