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
        testthat::expect_true(is.function(PkgDevel))
        testthat::expect_equal(names(formals(PkgDevel)), "path")
      }
    )
  },
  text = "test-rProject-pkg-devel"
)
