## ---- test-rProject-read-me
# The behavior of ReadMe() is tested with its family of functions;
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
          object = formals(fun = ReadMe),
          expected = c("path")
        )
      }
    )
  },
  text = "test-rProject-read-me"
)
