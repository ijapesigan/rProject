## ---- test-rProject-lib-shadowed
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    root <- .TestProject()
    other <- tempfile(pattern = "otherlib")
    fake <- function(lib, pkg) {
      dir.create(file.path(lib, pkg), recursive = TRUE)
      writeLines(
        text = c(
          paste("Package:", pkg), "Version: 0.0.1",
          "Built: R 4.5.0; ; 2026-01-01 00:00:00 UTC; unix"
        ),
        con = file.path(lib, pkg, "DESCRIPTION")
      )
    }
    lib <- file.path(root, ".library")
    for (pkg in c("dupPkg", "onlyHere", "rProject")) {
      fake(lib = lib, pkg = pkg)
    }
    for (pkg in c("dupPkg", "rProject")) {
      fake(lib = other, pkg = pkg)
    }
    testthat::test_that(
      paste(text, "names packages that the image also has"),
      {
        out <- suppressMessages(
          .LibShadowed(path = root, lib_paths = c(lib, other))
        )
        testthat::expect_equal(out, "dupPkg")
        testthat::expect_message(
          .LibShadowed(path = root, lib_paths = c(lib, other)),
          regexp = "make cleanpkg"
        )
      }
    )
    testthat::test_that(
      paste(text, "is quiet without duplicates"),
      {
        testthat::expect_length(
          .LibShadowed(path = root, lib_paths = lib),
          0
        )
      }
    )
    unlink(c(dirname(root), other), recursive = TRUE)
  },
  text = "test-rProject-lib-shadowed"
)
