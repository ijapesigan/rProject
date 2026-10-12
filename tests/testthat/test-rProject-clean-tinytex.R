## ---- test-rProject-clean-tinytex
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    # CleanTinyTex() removes the user's TinyTeX installation,
    # so the tests only check its interface.
    testthat::test_that(
      paste(text, "has the documented arguments"),
      {
        testthat::expect_true(is.function(CleanTinyTex))
        testthat::expect_equal(names(formals(CleanTinyTex)), "path")
      }
    )
  },
  text = "test-rProject-clean-tinytex"
)
