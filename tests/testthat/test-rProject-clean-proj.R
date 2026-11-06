## ---- test-rProject-clean-proj
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    fill <- function() {
      root <- .TestProject()
      for (dir in c(".library", ".sim", ".sif")) {
        dir.create(path = file.path(root, dir))
      }
      writeLines(text = "x", con = file.path(root, "project.Rproj"))
      writeLines(text = "x", con = file.path(root, "Makefile"))
      root
    }
    testthat::test_that(
      desc = paste(text, "empties the project but keeps the protected folders"),
      code = {
        root <- fill()
        CleanProj(path = root)
        left <- list.files(path = root, all.files = TRUE, no.. = TRUE)
        testthat::expect_setequal(
          object = left,
          expected = c(".library", ".sim", ".sif", "project.Rproj")
        )
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      desc = paste(text, "removes the protected folders when asked"),
      code = {
        root <- fill()
        CleanProj(path = root, lib = TRUE, sim = TRUE, sif = TRUE)
        left <- list.files(path = root, all.files = TRUE, no.. = TRUE)
        testthat::expect_equal(object = left, expected = "project.Rproj")
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-clean-proj"
)
