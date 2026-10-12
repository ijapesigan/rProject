## ---- test-rProject-latex-compile
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::test_that(
      paste(text, "compiles a LaTeX document to PDF (slow)"),
      {
        .SkipSlow()
        testthat::skip_if(Sys.which("latexmk") == "", "latexmk not found")
        root <- .TestProject()
        latex <- file.path(root, ".setup", "latex")
        dir.create(latex, recursive = TRUE)
        writeLines(
          text = c(
            "\\documentclass{article}",
            "\\begin{document}",
            "Hello.",
            "\\end{document}"
          ),
          con = file.path(latex, "testProject-test.tex")
        )
        suppressMessages(LatexKnit(path = root))
        suppressMessages(suppressWarnings(LatexCompile(path = root)))
        testthat::expect_true(
          length(list.files(
            root,
            pattern = "\\.pdf$",
            recursive = TRUE,
            all.files = TRUE
          )) > 0L
        )
        unlink(dirname(root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-latex-compile"
)
