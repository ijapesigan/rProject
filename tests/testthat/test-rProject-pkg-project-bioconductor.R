## ---- test-rProject-pkg-project-bioconductor
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    state <- .TestState()
    root <- .TestProject()
    testthat::test_that(
      desc = paste(text, "skips packages that are already installed"),
      code = {
        testthat::expect_silent(
          object = PkgProjectBioconductor(path = root, pkg = "stats")
        )
        testthat::expect_silent(
          object = PkgProjectBioconductor(
            path = root,
            pkg = character(length = 0)
          )
        )
      }
    )
    .TestRestore(state = state)
    unlink(x = dirname(path = root), recursive = TRUE)
  },
  text = "test-rProject-pkg-project-bioconductor"
)
