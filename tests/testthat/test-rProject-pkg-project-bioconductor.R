## ---- test-rProject-pkg-project-bioconductor
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    state <- .TestState()
    root <- .TestProject()
    testthat::test_that(
      paste(text, "skips packages that are already installed"),
      {
        testthat::expect_silent(
          PkgProjectBioconductor(path = root, pkg = "stats")
        )
        testthat::expect_silent(
          PkgProjectBioconductor(path = root, pkg = character(0))
        )
      }
    )
    .TestRestore(state)
    unlink(dirname(root), recursive = TRUE)
  },
  text = "test-rProject-pkg-project-bioconductor"
)
