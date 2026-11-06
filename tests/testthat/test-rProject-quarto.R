## ---- test-rProject-quarto
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::test_that(
      paste(text, "does nothing without .qmd files"),
      {
        root <- .TestProject()
        testthat::expect_message(
          object = Quarto(path = root),
          regexp = "No .qmd. files found"
        )
        testthat::expect_false(
          object = dir.exists(paths = file.path(root, "quarto"))
        )
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "renders a website (slow)"),
      {
        .SkipSlow()
        testthat::skip_if(condition = Sys.which(names = "quarto") == "")
        root <- .TestProject()
        dir.create(path = file.path(root, ".setup", "quarto"), recursive = TRUE)
        writeLines(
          text = c("project:", "  type: website", "  output-dir: quarto"),
          con = file.path(root, ".setup", "quarto", "_quarto.yml")
        )
        writeLines(
          text = c("# Home", "", "Hello."),
          con = file.path(root, "index.qmd")
        )
        suppressMessages(expr = suppressWarnings(expr = Quarto(path = root)))
        testthat::expect_true(
          object = length(
            x = list.files(path = root, pattern = "\\.html$", recursive = TRUE)
          ) > 0L
        )
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-quarto"
)
