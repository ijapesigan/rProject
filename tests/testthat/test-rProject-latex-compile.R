## ---- test-rProject-latex-compile
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::test_that(
      paste(text, "compiles a LaTeX document to PDF (slow)"),
      {
        .SkipSlow()
        testthat::skip_if(
          condition = Sys.which(names = "latexmk") == "",
          message = "latexmk not found"
        )
        root <- .TestProject(pattern = "project with space ")
        latex <- file.path(root, ".setup", "latex")
        dir.create(path = latex, recursive = TRUE)
        writeLines(
          text = c(
            "\\documentclass{article}",
            "\\begin{document}",
            "Hello.",
            "\\end{document}"
          ),
          con = file.path(latex, "testProject-test.tex")
        )
        suppressMessages(expr = LatexKnit(path = root))
        suppressMessages(
          expr = suppressWarnings(expr = LatexCompile(path = root))
        )
        testthat::expect_true(
          object = length(x = list.files(
            path = root,
            pattern = "\\.pdf$",
            recursive = TRUE,
            all.files = TRUE
          )) > 0L
        )
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-latex-compile"
)
