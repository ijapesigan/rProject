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
        testthat::expect_true(object = is.function(x = TinyTex))
        testthat::expect_equal(
          object = names(x = formals(fun = TinyTex)),
          expected = c("path", "bundle", "force")
        )
      }
    )
  },
  text = "test-rProject-tinytex"
)
