## ---- test-rProject-binary
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    root <- .TestProject()
    dir.create(path = file.path(root, ".setup", "bin", "sub"), recursive = TRUE)
    marker <- file.path(root, "ran.txt")
    writeLines(
      text = paste0("writeLines(\"bin\", ", deparse(expr = marker), ")"),
      con = file.path(root, ".setup", "bin", "sub", "make-bin.R")
    )
    testthat::test_that(
      desc = paste(text, "sources every R file in .setup/bin"),
      code = {
        Binary(path = root)
        testthat::expect_equal(
          object = readLines(con = marker),
          expected = "bin"
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "does nothing without .setup/bin"),
      code = {
        other <- .TestProject(name = "noBin")
        testthat::expect_null(object = Binary(path = other))
      }
    )
    unlink(x = dirname(path = root), recursive = TRUE)
  },
  text = "test-rProject-binary"
)
