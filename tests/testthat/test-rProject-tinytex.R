## ---- test-rProject-tinytex
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    # TinyTex() installs TinyTeX into the user's home folder,
    # so the tests only check its interface.
    testthat::test_that(
      paste(text, "has the documented arguments"),
      {
        testthat::expect_true(is.function(TinyTex))
        testthat::expect_equal(
          names(formals(TinyTex)),
          c("path", "bundle", "force")
        )
      }
    )
  },
  text = "test-rProject-tinytex"
)
