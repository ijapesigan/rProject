## ---- test-rProject-pkg-devel-git-hub
# The behavior of PkgDevelGitHub() is tested with its family of functions;
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
          object = formals(fun = PkgDevelGitHub),
          expected = c("path")
        )
      }
    )
  },
  text = "test-rProject-pkg-devel-git-hub"
)
