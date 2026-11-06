## ---- test-rProject-lint-sh-script
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::test_that(
      desc = paste(text, "flags what the rule forbids"),
      code = {
        root <- .TestLintProject(
          files = list("a.sh" = c("echo hi"))
        )
        rows <- .LintShScript(path = root)
        testthat::expect_setequal(
          object = rows$rule,
          expected = c("sh-shebang", "sh-strict")
        )
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      desc = paste(text, "passes what the rule allows"),
      code = {
        root <- .TestLintProject(
          files = list(
            "a.sh" = c("#!/usr/bin/env bash", "set -Eeuo pipefail"),
            "b.sh" = c("#!/bin/bash", "#SBATCH --nodes=1", "set -euo pipefail"),
            "c.sh" = c("#!/bin/bash", "", "# Helpers (sourced, not run).")
          )
        )
        testthat::expect_identical(
          object = nrow(x = .LintShScript(path = root)),
          expected = 0L
        )
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-lint-sh-script"
)
