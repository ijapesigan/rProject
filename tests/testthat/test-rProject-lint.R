## ---- test-rProject-lint
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::skip_if_not_installed("lintr")
    .SkipUnlessSiteLibrary(pkgs = c("lintr", "distro"))
    state <- .TestState()
    root <- .TestProject()
    testthat::test_that(
      paste(text, "reports lints with the house rules"),
      {
        writeLines("bad_Name = function( x ) x", file.path(root, "R", "a.R"))
        lints <- Lint(path = root)
        testthat::expect_s3_class(lints, "lints")
        testthat::expect_true(length(lints) > 0L)
      }
    )
    testthat::test_that(
      paste(text, "allows BigCamelCase and snake_case"),
      {
        writeLines(
          c("Foo <- function(x) {", "  my_value <- x", "  my_value", "}"),
          file.path(root, "R", "a.R")
        )
        testthat::expect_length(Lint(path = root), 0L)
      }
    )
    .TestRestore(state)
    unlink(dirname(root), recursive = TRUE)
  },
  text = "test-rProject-lint"
)
