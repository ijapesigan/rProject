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
          LatexMake(path = root),
          "\\.setup/latex does not exist"
        )
        testthat::expect_false(dir.exists(file.path(root, "detritus")))
        unlink(dirname(root), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "knits and compiles a document (slow)"),
      {
        .SkipSlow()
        testthat::skip_if(Sys.which("latexmk") == "")
        root <- .TestProject()
        dir.create(file.path(root, ".setup", "latex"), recursive = TRUE)
        writeLines(
          text = c(
            "\\documentclass{article}",
            "\\begin{document}",
            "Hello.",
            "\\end{document}"
          ),
          con = file.path(root, ".setup", "latex", "testProject-test.tex")
        )
        suppressMessages(suppressWarnings(LatexMake(path = root)))
        testthat::expect_true(
          length(
            list.files(
              root,
              pattern = "\\.pdf$",
              recursive = TRUE,
              all.files = TRUE
            )
          ) > 0L
        )
        unlink(dirname(root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-latex-make"
)
