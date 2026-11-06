## ---- test-rProject-detritus
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    root <- .TestProject()
    out <- Detritus(path = root)
    testthat::test_that(
      desc = paste(text, "creates the folders and a .gitignore"),
      code = {
        testthat::expect_true(
          object = dir.exists(paths = out$tex_figures_folder)
        )
        testthat::expect_match(
          object = basename(path = out$tex_figures_folder),
          regexp = "^tex-fig-"
        )
        testthat::expect_equal(
          object = readLines(
            con = file.path(out$detritus_folder, ".gitignore")
          ),
          expected = c("*", "*/")
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "keeps an existing .gitignore"),
      code = {
        writeLines(
          text = "custom",
          con = file.path(out$detritus_folder, ".gitignore")
        )
        Detritus(path = root)
        testthat::expect_equal(
          object = readLines(
            con = file.path(out$detritus_folder, ".gitignore")
          ),
          expected = "custom"
        )
      }
    )
    unlink(x = dirname(path = root), recursive = TRUE)
  },
  text = "test-rProject-detritus"
)
