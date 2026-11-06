## ---- test-rProject-latex-knit
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_if_not_installed(pkg = "knitr")
    root <- .TestProject()
    latex <- file.path(root, ".setup", "latex")
    dir.create(path = latex, recursive = TRUE)
    writeLines(
      text = c(
        "\\documentclass{article}", "\\begin{document}",
        "<<>>=", "1 + 1", "@", "\\end{document}"
      ),
      con = file.path(latex, "testProject-paper.Rtex")
    )
    writeLines(
      text = c(
        "\\documentclass{article}", "\\begin{document}", "Plain.",
        "\\end{document}"
      ),
      con = file.path(latex, "testProject-plain.tex")
    )
    testthat::test_that(
      desc = paste(text, "knits .Rtex and copies .tex into detritus/tex"),
      code = {
        suppressMessages(expr = LatexKnit(path = root))
        tex <- file.path(root, "detritus", "tex")
        knitted <- file.path(tex, "testProject-paper.tex")
        testthat::expect_true(object = file.exists(knitted))
        testthat::expect_true(
          object = any(
            grepl(pattern = "\\[1\\] 2", x = readLines(con = knitted))
          )
        )
        testthat::expect_true(
          object = file.exists(file.path(tex, "testProject-plain.tex"))
        )
      }
    )
    unlink(x = dirname(path = root), recursive = TRUE)
  },
  text = "test-rProject-latex-knit"
)
