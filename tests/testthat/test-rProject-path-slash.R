## ---- test-rProject-path-slash
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::test_that(
      paste(text, "turns backslashes into forward slashes"),
      {
        testthat::expect_equal(
          object = rProject:::.PathSlash(
            x = "C:\\Users\\a b\\project/.library"
          ),
          expected = "C:/Users/a b/project/.library"
        )
      }
    )
    testthat::test_that(
      paste(text, "leaves other paths unchanged"),
      {
        x <- c("/scratch/a b/project", "relative/path", "")
        testthat::expect_equal(
          object = rProject:::.PathSlash(x = x),
          expected = x
        )
      }
    )
  },
  text = "test-rProject-path-slash"
)
