## ---- test-rProject-pkg-repo
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::test_that(
      paste(text, "returns a Posit Package Manager URL"),
      {
        repo <- PkgRepo(path = tempdir())
        testthat::expect_length(repo, 1L)
        testthat::expect_match(
          repo,
          "^https://packagemanager\\.rstudio\\.com/all/"
        )
        testthat::expect_match(repo, "latest")
      }
    )
  },
  text = "test-rProject-pkg-repo"
)
