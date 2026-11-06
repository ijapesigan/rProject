## ---- test-rProject-clean-tinytex
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    # CleanTinyTex() removes the user's TinyTeX installation,
    # so the tests only check its interface.
    testthat::test_that(
      desc = paste(text, "has the documented arguments"),
      code = {
        testthat::expect_true(object = is.function(x = CleanTinyTex))
        testthat::expect_equal(
          object = names(x = formals(fun = CleanTinyTex)),
          expected = "path"
        )
      }
    )
  },
  text = "test-rProject-clean-tinytex"
)
