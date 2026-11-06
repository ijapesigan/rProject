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
        testthat::expect_true(object = dir.exists(paths = lib))
        testthat::expect_equal(
          object = normalizePath(path = .libPaths()[1]),
          expected = normalizePath(path = lib)
        )
        testthat::expect_equal(
          object = Sys.getenv(x = "R_LIBS_USER"),
          expected = lib
        )
        testthat::expect_equal(
          object = readLines(con = file.path(lib, ".gitignore")),
          expected = c("*", "*/")
        )
      }
    )
    .TestRestore(state = state)
    unlink(x = dirname(path = root), recursive = TRUE)
  },
  text = "test-rProject-lib-paths"
)
