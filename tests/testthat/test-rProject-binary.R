## ---- test-rProject-binary
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    root <- .TestProject()
    dir.create(file.path(root, ".setup", "bin", "sub"), recursive = TRUE)
    marker <- file.path(root, "ran.txt")
    writeLines(
      text = paste0("writeLines(\"bin\", ", deparse(marker), ")"),
      con = file.path(root, ".setup", "bin", "sub", "make-bin.R")
    )
    testthat::test_that(
      paste(text, "sources every R file in .setup/bin"),
      {
        Binary(path = root)
        testthat::expect_equal(readLines(marker), "bin")
      }
    )
    testthat::test_that(
      paste(text, "does nothing without .setup/bin"),
      {
        other <- .TestProject(name = "noBin")
        testthat::expect_null(Binary(path = other))
      }
    )
    unlink(dirname(root), recursive = TRUE)
  },
  text = "test-rProject-binary"
)
