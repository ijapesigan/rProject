## ---- test-rProject-latex-make
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::test_that(
      paste(text, "says so and does nothing without .setup/latex"),
      {
        root <- .TestProject()
        testthat::expect_message(
          object = LatexMake(path = root),
          regexp = "\\.setup/latex does not exist"
        )
        testthat::expect_false(
          object = dir.exists(paths = file.path(root, "detritus"))
        )
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "knits and compiles a document (slow)"),
      {
        .SkipSlow()
        testthat::skip_if(condition = Sys.which(names = "latexmk") == "")
        root <- .TestProject()
        dir.create(path = file.path(root, ".setup", "latex"), recursive = TRUE)
        writeLines(
          text = c(
            "\\documentclass{article}",
            "\\begin{document}",
            "Hello.",
            "\\end{document}"
          ),
          con = file.path(root, ".setup", "latex", "testProject-test.tex")
        )
        suppressMessages(expr = suppressWarnings(expr = LatexMake(path = root)))
        testthat::expect_true(
          object = length(
            x = list.files(
              path = root,
              pattern = "\\.pdf$",
              recursive = TRUE,
              all.files = TRUE
            )
          ) > 0L
        )
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-latex-make"
)
