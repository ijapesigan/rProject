## ---- test-rProject-license
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::test_that(
      desc = paste(text, "copies the MIT license"),
      code = {
        root <- .TestProject()
        License(path = root, type = "mit")
        testthat::expect_true(
          object = all(file.exists(file.path(root, c("LICENSE", "LICENSE.md"))))
        )
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      desc = paste(text, "copies the GPL-3 license"),
      code = {
        root <- .TestProject()
        License(path = root, type = "gpl3")
        testthat::expect_true(
          object = file.exists(file.path(root, "LICENSE.md"))
        )
        testthat::expect_false(object = file.exists(file.path(root, "LICENSE")))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      desc = paste(text, "copies nothing for NULL"),
      code = {
        root <- .TestProject()
        License(path = root, type = NULL)
        testthat::expect_false(
          object = any(file.exists(file.path(root, c("LICENSE", "LICENSE.md"))))
        )
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-license"
)
