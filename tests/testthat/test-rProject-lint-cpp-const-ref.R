## ---- test-rProject-lint-cpp-const-ref
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::test_that(
      desc = paste(text, "flags what the rule forbids"),
      code = {
        root <- .TestLintProject(
          files = list(
            ".setup/cpp/testProject-foo-dot.cpp" = c(
              "double Foo(arma::mat x) {",
              "  return 1;",
              "}"
            )
          )
        )
        rows <- .LintCppConstRef(path = root)
        testthat::expect_true(object = any(rows$rule == "cpp-const-ref"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      desc = paste(text, "passes what the rule allows"),
      code = {
        root <- .TestLintProject(
          files = list(
            ".setup/cpp/testProject-foo-dot.cpp" = c(
              "double Foo(const arma::mat& x) {",
              "  return 1;",
              "}"
            )
          )
        )
        rows <- .LintCppConstRef(path = root)
        testthat::expect_false(object = any(rows$rule == "cpp-const-ref"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-lint-cpp-const-ref"
)
