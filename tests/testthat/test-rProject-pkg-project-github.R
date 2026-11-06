## ---- test-rProject-pkg-project-github
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    state <- .TestState()
    root <- .TestProject()
    testthat::test_that(
      paste(text, "does nothing without packages"),
      {
        testthat::expect_null(
          object = PkgProjectGitHub(path = root, pkg = character(length = 0))
        )
      }
    )
    testthat::test_that(
      paste(text, "needs one ref per package"),
      {
        testthat::expect_error(
          object = PkgProjectGitHub(
            path = root,
            pkg = c("owner/a", "owner/b"),
            ref = "main"
          )
        )
      }
    )
    .TestRestore(state = state)
    unlink(x = dirname(path = root), recursive = TRUE)
  },
  text = "test-rProject-pkg-project-github"
)
