## ---- test-rProject-shell-quote
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::test_that(
      paste(text, "keeps a path with spaces as one argument"),
      {
        root <- file.path(tempfile(pattern = "shell quote"), "a b")
        dir.create(root, recursive = TRUE)
        writeLines("x", file.path(root, "file.txt"))
        out <- system2(
          command = file.path(R.home("bin"), "Rscript"),
          args = c(
            "-e",
            rProject:::.ShellQuote(x = "cat(file.exists(commandArgs(TRUE)))"),
            rProject:::.ShellQuote(x = file.path(root, "file.txt"))
          ),
          stdout = TRUE
        )
        testthat::expect_equal(out, "TRUE")
        unlink(dirname(root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-shell-quote"
)
