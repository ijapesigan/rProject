## ---- test-rProject-quarto
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::test_that(
      paste(text, "does nothing without .qmd files"),
      {
        root <- .TestProject()
        testthat::expect_message(Quarto(path = root), "No .qmd. files found")
        testthat::expect_false(dir.exists(file.path(root, "quarto")))
        unlink(dirname(root), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "renders a website (slow)"),
      {
        .SkipSlow()
        testthat::skip_if(Sys.which("quarto") == "")
        root <- .TestProject()
        dir.create(file.path(root, ".setup", "quarto"), recursive = TRUE)
        writeLines(
          c("project:", "  type: website", "  output-dir: quarto"),
          file.path(root, ".setup", "quarto", "_quarto.yml")
        )
        writeLines(c("# Home", "", "Hello."), file.path(root, "index.qmd"))
        suppressMessages(suppressWarnings(Quarto(path = root)))
        testthat::expect_true(
          length(list.files(root, pattern = "\\.html$", recursive = TRUE)) > 0L
        )
        unlink(dirname(root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-quarto"
)
