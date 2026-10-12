## ---- test-rProject-path-slash
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::test_that(
      paste(text, "turns backslashes into forward slashes"),
      {
        testthat::expect_equal(
          rProject:::.PathSlash(x = "C:\\Users\\a b\\project/.library"),
          "C:/Users/a b/project/.library"
        )
      }
    )
    testthat::test_that(
      paste(text, "leaves other paths unchanged"),
      {
        x <- c("/scratch/a b/project", "relative/path", "")
        testthat::expect_equal(rProject:::.PathSlash(x = x), x)
      }
    )
  },
  text = "test-rProject-path-slash"
)
