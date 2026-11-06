## ---- test-rProject-data-manifest
# The behavior of DataManifest() is tested with its family of functions;
# this keeps its arguments stable.
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::test_that(
      paste(text, "keeps its arguments"),
      {
        testthat::expect_named(
          object = formals(fun = DataManifest),
          expected = c("path")
        )
      }
    )
  },
  text = "test-rProject-data-manifest"
)
