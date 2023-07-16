## ---- test
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::test_that(
      text,
      {
        testthat::expect_equal(
          1,
          1
        )
      }
    )
  },
  text = "test"
)
