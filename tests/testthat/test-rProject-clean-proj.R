## ---- test-rProject-clean-proj
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    fill <- function() {
      root <- .TestProject()
      for (dir in c(".library", ".sim", ".sif")) {
        dir.create(file.path(root, dir))
      }
      writeLines(text = "x", con = file.path(root, "project.Rproj"))
      writeLines(text = "x", con = file.path(root, "Makefile"))
      root
    }
    testthat::test_that(
      paste(text, "empties the project but keeps the protected folders"),
      {
        root <- fill()
        CleanProj(path = root)
        left <- list.files(root, all.files = TRUE, no.. = TRUE)
        testthat::expect_setequal(
          left,
          c(".library", ".sim", ".sif", "project.Rproj")
        )
        unlink(dirname(root), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "removes the protected folders when asked"),
      {
        root <- fill()
        CleanProj(path = root, lib = TRUE, sim = TRUE, sif = TRUE)
        left <- list.files(root, all.files = TRUE, no.. = TRUE)
        testthat::expect_equal(left, "project.Rproj")
        unlink(dirname(root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-clean-proj"
)
