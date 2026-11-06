## ---- test-rProject-pkg-devel-github
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    # PkgDevelGitHub() installs packages from GitHub,
    # so the tests only check its interface.
    testthat::test_that(
      paste(text, "has the documented arguments"),
      {
        testthat::expect_true(object = is.function(x = PkgDevelGitHub))
        testthat::expect_equal(
          object = names(x = formals(fun = PkgDevelGitHub)),
          expected = "path"
        )
      }
    )
  },
  text = "test-rProject-pkg-devel-github"
)
