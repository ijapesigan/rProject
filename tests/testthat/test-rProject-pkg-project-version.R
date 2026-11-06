## ---- test-rProject-pkg-project-version
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_if_not_installed(pkg = "remotes")
    .SkipUnlessSiteLibrary(pkgs = c("remotes", "distro"))
    state <- .TestState()
    root <- .TestProject()
    testthat::test_that(
      desc = paste(text, "needs one version per package"),
      code = {
        testthat::expect_error(
          object = PkgProjectVersion(
            path = root,
            pkg = "stats",
            ver = c("1", "2")
          )
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "skips a package that already has the version"),
      code = {
        testthat::expect_silent(
          object = PkgProjectVersion(
            path = root,
            pkg = "stats",
            ver = as.character(x = utils::packageVersion(pkg = "stats"))
          )
        )
      }
    )
    .TestRestore(state = state)
    unlink(x = dirname(path = root), recursive = TRUE)
  },
  text = "test-rProject-pkg-project-version"
)
