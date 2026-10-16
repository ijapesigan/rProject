## ---- test-rProject-bib
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    entry <- function(key, title) {
      c(
        paste0("@Article{", key, ","),
        "  author = {Jane Doe and Lee M{\\'e}n},",
        paste0("  title = {", title, "},"),
        "  journaltitle = {Journal},",
        "  date = {2020},",
        "}"
      )
    }
    testthat::test_that(
      paste(text, "joins .bib files verbatim and copies them"),
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
        testthat::expect_equal(
          merged,
          c(entry("Doe-2020a", "First"), "", entry("Doe-2020b", "Second"), "")
        )
        # the sources are not rewritten, and bib.bib is not a source
        testthat::expect_equal(
          readLines(file.path(bib_dir, "a.bib")),
          entry("Doe-2020a", "First")
        )
        suppressMessages(Bib(path = root))
        testthat::expect_equal(readLines(file.path(bib_dir, "bib.bib")), merged)
        testthat::expect_equal(
          readLines(file.path(root, ".setup", "quarto", "bib", "quarto.bib")),
          merged
        )
        testthat::expect_true(
          file.exists(file.path(root, "vignettes", "vignettes.bib"))
        )
        unlink(dirname(root), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "copies an existing bib.bib without sources"),
      {
        root <- .TestProject()
        bib_dir <- file.path(root, ".setup", "latex", "bib")
        dir.create(bib_dir, recursive = TRUE)
        dir.create(file.path(root, ".setup", "quarto"))
        dir.create(file.path(root, "vignettes"))
        merged <- c(entry("Doe-2020a", "First"), "")
        writeLines(merged, file.path(bib_dir, "bib.bib"))
        testthat::expect_silent(out <- Bib(path = root))
        testthat::expect_equal(out, file.path(bib_dir, "bib.bib"))
        testthat::expect_equal(readLines(file.path(bib_dir, "bib.bib")), merged)
        testthat::expect_equal(
          readLines(file.path(root, ".setup", "quarto", "bib", "quarto.bib")),
          merged
        )
        testthat::expect_equal(
          readLines(file.path(root, "vignettes", "vignettes.bib")),
          merged
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
