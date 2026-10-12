## ---- test-rProject-license
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::test_that(
      paste(text, "copies the MIT license"),
      {
        root <- .TestProject()
        License(path = root, type = "mit")
        testthat::expect_true(
          all(file.exists(file.path(root, c("LICENSE", "LICENSE.md"))))
        )
        unlink(dirname(root), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "copies the GPL-3 license"),
      {
        root <- .TestProject()
        License(path = root, type = "gpl3")
        testthat::expect_true(file.exists(file.path(root, "LICENSE.md")))
        testthat::expect_false(file.exists(file.path(root, "LICENSE")))
        unlink(dirname(root), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "copies nothing for NULL"),
      {
        root <- .TestProject()
        License(path = root, type = NULL)
        testthat::expect_false(
          any(file.exists(file.path(root, c("LICENSE", "LICENSE.md"))))
        )
        unlink(dirname(root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-license"
)
