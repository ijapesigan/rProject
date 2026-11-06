## ---- test-rProject-lint-cpp-names
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
              "double foo_bar(const double Xvalue) {",
              "  return Xvalue;",
              "}"
            )
          )
        )
        rows <- .LintCppNames(path = root)
        testthat::expect_true(object = any(rows$rule == "cpp-names"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "passes what the rule allows"),
      {
        root <- .TestLintProject(
          files = list(
            ".setup/cpp/testProject-foo-dot.cpp" = c(
              "double FooBar(const double x_value) {",
              "  return x_value;",
              "}"
            )
          )
        )
        rows <- .LintCppNames(path = root)
        testthat::expect_false(object = any(rows$rule == "cpp-names"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-lint-cpp-names"
)
