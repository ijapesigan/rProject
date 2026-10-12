## ---- test-rProject-detritus
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    root <- .TestProject()
    out <- Detritus(path = root)
    testthat::test_that(
      paste(text, "creates the folders and a .gitignore"),
      {
        testthat::expect_true(dir.exists(out$tex_figures_folder))
        testthat::expect_match(basename(out$tex_figures_folder), "^tex-fig-")
        testthat::expect_equal(
          readLines(file.path(out$detritus_folder, ".gitignore")),
          c("*", "*/")
        )
      }
    )
    testthat::test_that(
      paste(text, "keeps an existing .gitignore"),
      {
        writeLines("custom", file.path(out$detritus_folder, ".gitignore"))
        Detritus(path = root)
        testthat::expect_equal(
          readLines(file.path(out$detritus_folder, ".gitignore")),
          "custom"
        )
      }
    )
    unlink(dirname(root), recursive = TRUE)
  },
  text = "test-rProject-detritus"
)
