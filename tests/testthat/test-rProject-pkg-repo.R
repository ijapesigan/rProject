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
        # the image's snapshot (a date), or latest
        testthat::expect_match(repo, "latest|/\\d{4}-\\d{2}-\\d{2}")
      }
    )
  },
  text = "test-rProject-pkg-repo"
)
