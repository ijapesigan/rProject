## ---- test-rProject-coverage
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::test_that(
      desc = paste(text, "skips folders that are not packages"),
      code = {
        root <- .TestProject(description = FALSE)
        testthat::expect_message(
          object = Coverage(path = root),
          regexp = "is not an R package"
        )
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      desc = paste(text, "runs covr with the tests skip_on_cran() guards"),
      code = {
        testthat::skip_if_not_installed(pkg = "covr")
        root <- .TestProject()
        testthat::local_mocked_bindings(
          LibPaths = function(path) {
            .libPaths()[1]
          }
        )
        # what a test guarded by skip_on_cran() does under covr
        testthat::local_mocked_bindings(
          package_coverage = function(path) {
            tryCatch(
              expr = {
                testthat::skip_on_cran()
                "ran"
              },
              skip = function(e) {
                "skipped"
              }
            )
          },
          .package = "covr"
        )
        testthat::expect_equal(
          object = Coverage(path = root),
          expected = "ran"
        )
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-coverage"
)
