## ---- test-rProject-bib
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_if_not_installed("RefManageR")
    entry <- function(key, title) {
      c(
        paste0("@Article{", key, ","),
        "  author = {Doe, Jane},",
        paste0("  title = {", title, "},"),
        "  journal = {Journal},",
        "  year = {2020},",
        "}"
      )
    }
    testthat::test_that(
      paste(text, "merges .bib files, copies them for quarto and vignettes"),
      {
        root <- .TestProject()
        bib_dir <- file.path(root, ".setup", "latex", "bib")
        dir.create(bib_dir, recursive = TRUE)
        dir.create(file.path(root, ".setup", "quarto"))
        dir.create(file.path(root, "vignettes"))
        writeLines(entry("Doe-2020a", "First"), file.path(bib_dir, "a.bib"))
        writeLines(entry("Doe-2020b", "Second"), file.path(bib_dir, "b.bib"))
        suppressMessages(Bib(path = root))
        merged <- readLines(file.path(bib_dir, "bib.bib"))
        testthat::expect_true(any(grepl("Doe-2020a", merged)))
        testthat::expect_true(any(grepl("Doe-2020b", merged)))
        testthat::expect_true(
          file.exists(file.path(root, ".setup", "quarto", "bib", "quarto.bib"))
        )
        testthat::expect_true(
          file.exists(file.path(root, "vignettes", "vignettes.bib"))
        )
        unlink(dirname(root), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "says so when there are no .bib files"),
      {
        root <- .TestProject()
        testthat::expect_message(
          out <- Bib(path = root),
          "No \".bib\" files found"
        )
        testthat::expect_null(out)
        dir.create(file.path(root, ".setup", "latex", "bib"), recursive = TRUE)
        testthat::expect_message(Bib(path = root), "No \".bib\" files found")
        unlink(dirname(root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-bib"
)
