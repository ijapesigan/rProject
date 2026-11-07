## ---- test-rProject-latex-make
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::test_that(
      desc = paste(text, "says so and does nothing without .setup/latex"),
      code = {
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
      desc = paste(text, "stops when the PDF build fails"),
      code = {
        root <- .TestProject()
        dir.create(
          path = file.path(root, ".setup", "latex", "bib"),
          recursive = TRUE
        )
        file.create(file.path(root, ".setup", "latex", "bib", "bib.bib"))
        testthat::with_mocked_bindings(
          code = testthat::expect_error(
            object = LatexMake(path = root),
            regexp = "LaTeX failed"
          ),
          LatexKnit = function(...) {
            NULL
          },
          LatexTikzCompile = function(...) {
            NULL
          },
          LatexCompile = function(...) {
            stop("LaTeX failed", call. = FALSE)
          }
        )
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      desc = paste(text, "knits and compiles a document (slow)"),
      code = {
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
