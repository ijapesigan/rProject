## ---- test-rProject-lint-cpp-files
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::test_that(
      desc = paste(text, "flags what the rule forbids"),
      code = {
        root <- .TestLintProject(
          files = list(".setup/cpp/001-helpers.cpp" = c("int x;"))
        )
        rows <- .LintCppFiles(path = root)
        testthat::expect_true(object = any(rows$rule == "cpp-file-name"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      desc = paste(text, "passes what the rule allows"),
      code = {
        root <- .TestLintProject(
          files = list(".setup/cpp/testProject-foo-dot.cpp" = c("int x;"))
        )
        rows <- .LintCppFiles(path = root)
        testthat::expect_false(object = any(rows$rule == "cpp-file-name"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-lint-cpp-files"
)
