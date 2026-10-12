## ---- test-rProject-lib-paths
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    state <- .TestState()
    root <- .TestProject()
    lib <- LibPaths(path = root)
    testthat::test_that(
      paste(text, "creates .library first in the library paths"),
      {
        testthat::expect_true(dir.exists(lib))
        testthat::expect_equal(
          normalizePath(.libPaths()[1]),
          normalizePath(lib)
        )
        testthat::expect_equal(Sys.getenv("R_LIBS_USER"), lib)
        testthat::expect_equal(
          readLines(file.path(lib, ".gitignore")),
          c("*", "*/")
        )
      }
    )
    .TestRestore(state)
    unlink(dirname(root), recursive = TRUE)
  },
  text = "test-rProject-lib-paths"
)
