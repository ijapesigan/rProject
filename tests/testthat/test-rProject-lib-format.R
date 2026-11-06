## ---- test-rProject-lib-format
# The behavior of LibFormat() is tested with its family of functions;
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
          object = formals(fun = LibFormat),
          expected = c("path", "write")
        )
      }
    )
  },
  text = "test-rProject-lib-format"
)
