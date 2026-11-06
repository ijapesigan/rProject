## ---- test-rProject-latex-tikz-compile
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::skip_if(
      condition = Sys.which(names = "latexmk") == "",
      message = "latexmk not found"
    )
    testthat::test_that(
      paste(text, "copies latexmkrc and does nothing without TikZ files"),
      {
        root <- .TestProject(pattern = "project with space ")
        suppressMessages(expr = LatexTikzCompile(path = root))
        testthat::expect_true(
          object = file.exists(file.path(root, "latexmkrc"))
        )
        testthat::expect_false(
          object = dir.exists(paths = file.path(root, "detritus"))
        )
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "compiles a TikZ figure to PDF (slow)"),
      {
        .SkipSlow()
        root <- .TestProject(pattern = "project with space ")
        tikz <- file.path(root, ".setup", "latex", "tikz")
        dir.create(path = tikz, recursive = TRUE)
        writeLines(
          text = c(
            "\\documentclass[tikz]{standalone}",
            "\\begin{document}",
            "\\begin{tikzpicture}\\draw (0,0) -- (1,1);\\end{tikzpicture}",
            "\\end{document}"
          ),
          con = file.path(tikz, "figure.tex")
        )
        suppressMessages(
          expr = suppressWarnings(expr = LatexTikzCompile(path = root))
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
  text = "test-rProject-latex-tikz-compile"
)
