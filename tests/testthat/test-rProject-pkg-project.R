## ---- test-rProject-pkg-project
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    state <- .TestState()
    root <- .TestProject()
    testthat::test_that(
      paste(text, "skips packages that are already installed"),
      {
        testthat::expect_silent(PkgProject(path = root, pkg = "stats"))
        testthat::expect_silent(PkgProject(path = root, pkg = character(0)))
      }
    )
    testthat::test_that(
      paste(text, "installs a missing CRAN package (slow)"),
      {
        .SkipSlow()
        testthat::skip_if_offline()
        utils::capture.output(PkgProject(path = root, pkg = "fortunes"))
        testthat::expect_true(
          dir.exists(file.path(root, ".library", "fortunes"))
        )
      }
    )
    .TestRestore(state)
    unlink(dirname(root), recursive = TRUE)
  },
  text = "test-rProject-pkg-project"
)
