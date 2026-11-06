## ---- test-rProject-path-slash
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::test_that(
      desc = paste(text, "turns backslashes into forward slashes"),
      code = {
        testthat::expect_equal(
          object = rProject:::.PathSlash(
            x = "C:\\Users\\a b\\project/.library"
          ),
          expected = "C:/Users/a b/project/.library"
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "leaves other paths unchanged"),
      code = {
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
