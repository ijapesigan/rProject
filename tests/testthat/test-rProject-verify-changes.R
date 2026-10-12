## ---- test-rProject-verify-changes
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    root <- tempfile(pattern = "verifychanges")
    path <- file.path(root, "project")
    private <- file.path(root, "private")
    for (dir in c(path, private)) {
      dir.create(file.path(dir, "inst", "latexmk"), recursive = TRUE)
      writeLines("same", file.path(dir, "R.R"))
    }
    writeLines("local", file.path(path, "inst", "latexmk", "latexmkrc"))
    writeLines("overleaf", file.path(private, "inst", "latexmk", "latexmkrc"))
    writeLines("local", file.path(path, "latexmkrc"))
    writeLines("overleaf", file.path(private, "latexmkrc"))
    out <- rProject:::.VerifyChanges(path = path, private = private)
    testthat::test_that(
      paste(text, "compares inst/latexmk/latexmkrc"),
      {
        testthat::expect_true("inst/latexmk/latexmkrc" %in% names(out))
      }
    )
    testthat::test_that(
      paste(text, "skips the root latexmkrc that LatexCompile() writes"),
      {
        testthat::expect_false("latexmkrc" %in% names(out))
        testthat::expect_false("R.R" %in% names(out))
      }
    )
    unlink(root, recursive = TRUE)
  },
  text = "test-rProject-verify-changes"
)
