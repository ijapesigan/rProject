## ---- test-rProject-build
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::test_that(
      desc = paste(text, "skips folders that are not packages"),
      code = {
        root <- .TestProject(description = FALSE)
        testthat::expect_message(
          object = Build(path = root),
          regexp = "is not an R package"
        )
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-build"
)
