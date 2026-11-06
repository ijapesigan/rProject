## ---- test-rProject-lint-cpp-format
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    .SkipIfMissingFormat <- function() {
      testthat::skip_if(
        condition = Sys.which(names = "clang-format") == "",
        message = "clang-format is not installed"
      )
    }
    testthat::test_that(
      paste(text, "reports unformatted C++ and passes formatted C++"),
      {
        .SkipIfMissingFormat()
        root <- .TestLintProject(
          files = list(
            ".setup/cpp/testProject-a.cpp" = c(
              "int  Foo( int x ){ if (x) return 1; return 2; }"
            )
          )
        )
        rows <- .LintCppFormat(path = root)
        testthat::expect_true(object = any(rows$rule == "cpp-format"))
        writeLines(
          text = c(
            "int Foo(int x) {",
            "  if (x) {",
            "    return 1;",
            "  }",
            "  return 2;",
            "}"
          ),
          con = file.path(root, ".setup", "cpp", "testProject-a.cpp")
        )
        rows <- .LintCppFormat(path = root)
        testthat::expect_false(object = any(rows$rule == "cpp-format"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-lint-cpp-format"
)
