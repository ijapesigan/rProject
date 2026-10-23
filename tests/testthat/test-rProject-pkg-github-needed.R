## ---- test-rProject-pkg-github-needed
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    sha <- "0123456789abcdef0123456789abcdef01234567"
    testthat::test_that(
      paste(text, "installs a missing package"),
      {
        testthat::expect_true(.PkgGitHubNeeded(installed = FALSE))
      }
    )
    testthat::test_that(
      paste(text, "never upgrades for a branch or tag"),
      {
        testthat::expect_false(.PkgGitHubNeeded(installed = TRUE))
        testthat::expect_false(
          .PkgGitHubNeeded(installed = TRUE, ref = "main", sha = sha)
        )
        testthat::expect_false(
          .PkgGitHubNeeded(installed = TRUE, ref = "v1.0.0")
        )
      }
    )
    testthat::test_that(
      paste(text, "reinstalls only for a different commit SHA"),
      {
        testthat::expect_false(
          .PkgGitHubNeeded(installed = TRUE, ref = sha, sha = sha)
        )
        testthat::expect_false(
          .PkgGitHubNeeded(installed = TRUE, ref = "0123456", sha = sha)
        )
        testthat::expect_true(
          .PkgGitHubNeeded(installed = TRUE, ref = "fedcba9", sha = sha)
        )
        testthat::expect_true(
          .PkgGitHubNeeded(installed = TRUE, ref = sha, sha = NA_character_)
        )
      }
    )
  },
  text = "test-rProject-pkg-github-needed"
)
