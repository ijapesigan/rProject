## ---- test-rProject-pkg-project-version
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_if_not_installed("remotes")
    state <- .TestState()
    root <- .TestProject()
    testthat::test_that(
      paste(text, "needs one version per package"),
      {
        testthat::expect_error(
          PkgProjectVersion(path = root, pkg = "stats", ver = c("1", "2"))
        )
      }
    )
    testthat::test_that(
      paste(text, "skips a package that already has the version"),
      {
        testthat::expect_silent(
          PkgProjectVersion(
            path = root,
            pkg = "stats",
            ver = as.character(utils::packageVersion("stats"))
          )
        )
      }
    )
    .TestRestore(state)
    unlink(dirname(root), recursive = TRUE)
  },
  text = "test-rProject-pkg-project-version"
)
