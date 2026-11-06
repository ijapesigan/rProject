## ---- test-rProject-lint-cpp-namespace
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
            ".setup/cpp/testProject-foo-dot.cpp" = c("using namespace arma;")
          )
        )
        rows <- .LintCppNamespace(path = root)
        testthat::expect_true(object = any(rows$rule == "cpp-namespace"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      desc = paste(text, "passes what the rule allows"),
      code = {
        root <- .TestLintProject(
          files = list(
            ".setup/cpp/testProject-foo-dot.cpp" = c(
              "// using namespace is not used"
            )
          )
        )
        rows <- .LintCppNamespace(path = root)
        testthat::expect_false(object = any(rows$rule == "cpp-namespace"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-lint-cpp-namespace"
)
