## ---- test-rProject-lib-add
# The behavior of LibAdd() is tested with its family of functions;
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
          object = formals(fun = LibAdd),
          expected = c("doi", "root", "key", "title", "fields", "write")
        )
      }
    )
  },
  text = "test-rProject-lib-add"
)
