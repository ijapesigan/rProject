## ---- test-rProject-lint-r-braces
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::test_that(
      paste(text, "flags what the rule forbids"),
      {
        root <- .TestLintProject(
          files = list("R/x.R" = c("F <- function(x) x", "if (TRUE) 1 else 2"))
        )
        rows <- .LintRBraces(path = root)
        testthat::expect_true(object = any(rows$rule == "braces"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "passes what the rule allows"),
      {
        root <- .TestLintProject(
          files = list(
            "R/x.R" = c(
              "F <- function(x) {",
              "  if (x) {",
              "    1",
              "  } else if (!x) {",
              "    2",
              "  }",
              "}"
            )
          )
        )
        rows <- .LintRBraces(path = root)
        testthat::expect_false(object = any(rows$rule == "braces"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-lint-r-braces"
)
