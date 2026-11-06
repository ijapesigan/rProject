## ---- test-rProject-tiny-tex
# The behavior of TinyTex() is tested with its family of functions;
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
          object = formals(fun = TinyTex),
          expected = c("path", "bundle", "force")
        )
      }
    )
  },
  text = "test-rProject-tiny-tex"
)
