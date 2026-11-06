## ---- test-rProject-lint-cpp-header
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
            ".setup/cpp/testProject-foo-dot.cpp" = c(
              "// edit .setup/cpp/other.cpp"
            )
          )
        )
        rows <- .LintCppHeader(path = root)
        testthat::expect_true(object = any(rows$rule == "cpp-header"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "passes what the rule allows"),
      {
        root <- .TestLintProject(
          files = list(
            ".setup/cpp/testProject-foo-dot.cpp" = c(
              "// edit .setup/cpp/testProject-foo-dot.cpp"
            )
          )
        )
        rows <- .LintCppHeader(path = root)
        testthat::expect_false(object = any(rows$rule == "cpp-header"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-lint-cpp-header"
)
