## ---- test-rProject-data-path
# The behavior of DataPath() is tested with its family of functions;
# this keeps its arguments stable.
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::test_that(
      desc = paste(text, "keeps its arguments"),
      code = {
        testthat::expect_named(
          object = formals(fun = DataPath),
          expected = c("path", "file", "plain")
        )
      }
    )
  },
  text = "test-rProject-data-path"
)
