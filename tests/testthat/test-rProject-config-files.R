## ---- test-rProject-config-files
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::test_that(
      paste(text, "stops when the clone fails"),
      {
        testthat::skip_on_cran()
        testthat::skip_if_offline(host = "github.com")
        testthat::expect_error(
          suppressWarnings(
            ConfigFiles(repo = "ijapesigan/this-repo-does-not-exist")
          ),
          regexp = "Could not clone"
        )
      }
    )
  },
  text = "test-rProject-config-files"
)
