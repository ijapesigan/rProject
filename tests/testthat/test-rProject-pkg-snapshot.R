## ---- test-rProject-pkg-snapshot
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    state <- .TestState(vars = "RPROJECT_SNAPSHOT")
    root <- .TestProject()
    none <- file.path(root, "none.json")
    labels <- file.path(root, "labels.json")
    writeLines(
      text = c(
        "{",
        "  \"org.opencontainers.image.created\": \"2026-10-22T16:33:24Z\"",
        "}"
      ),
      con = labels
    )
    testthat::test_that(
      paste(text, "is latest without an image, a lock, or the variable"),
      {
        Sys.unsetenv("RPROJECT_SNAPSHOT")
        testthat::expect_equal(
          .PkgSnapshot(path = root, labels = none),
          "latest"
        )
      }
    )
    testthat::test_that(
      paste(text, "takes the lock, then the sif, then the variable"),
      {
        writeLines(
          text = "snapshot <- \"2026-01-02\"",
          con = file.path(root, ".setup", "scripts", "rproject.lock")
        )
        testthat::expect_equal(
          .PkgSnapshot(path = root, labels = none),
          "2026-01-02"
        )
        testthat::expect_equal(
          .PkgSnapshot(path = root, labels = labels),
          "2026-10-22"
        )
        Sys.setenv(RPROJECT_SNAPSHOT = "2025-05-05")
        testthat::expect_equal(
          .PkgSnapshot(path = root, labels = labels),
          "2025-05-05"
        )
        Sys.setenv(RPROJECT_SNAPSHOT = "latest")
        testthat::expect_equal(
          .PkgSnapshot(path = root, labels = labels),
          "2026-10-22"
        )
      }
    )
    .TestRestore(state)
    unlink(dirname(root), recursive = TRUE)
  },
  text = "test-rProject-pkg-snapshot"
)
