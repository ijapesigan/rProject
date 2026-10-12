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
        testthat::expect_true(is.function(PkgDevelGitHub))
        testthat::expect_equal(names(formals(PkgDevelGitHub)), "path")
      }
    )
  },
  text = "test-rProject-pkg-devel-github"
)
