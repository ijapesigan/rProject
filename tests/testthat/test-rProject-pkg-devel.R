## ---- test-rProject-pkg-devel
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    # PkgDevel() installs about 30 packages,
    # so the tests only check its interface.
    testthat::test_that(
      paste(text, "has the documented arguments"),
      {
        testthat::expect_true(object = is.function(x = PkgDevel))
        testthat::expect_equal(
          object = names(x = formals(fun = PkgDevel)),
          expected = "path"
        )
      }
    )
  },
  text = "test-rProject-pkg-devel"
)
