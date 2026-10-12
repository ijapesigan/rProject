## ---- test-rProject-coverage
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::test_that(
      paste(text, "skips folders that are not packages"),
      {
        root <- .TestProject(description = FALSE)
        testthat::expect_message(
          Coverage(path = root),
          "is not an R package"
        )
        unlink(dirname(root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-coverage"
)
