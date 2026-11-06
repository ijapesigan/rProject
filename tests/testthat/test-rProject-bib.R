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
        dir.create(path = bib_dir, recursive = TRUE)
        dir.create(path = file.path(root, ".setup", "quarto"))
        dir.create(path = file.path(root, "vignettes"))
        writeLines(
          text = entry("Doe-2020a", "First"),
          con = file.path(bib_dir, "a.bib")
        )
        writeLines(
          text = entry("Doe-2020b", "Second"),
          con = file.path(bib_dir, "b.bib")
        )
        suppressMessages(expr = Bib(path = root))
        merged <- readLines(con = file.path(bib_dir, "bib.bib"))
        testthat::expect_equal(
          object = merged,
          expected = c(
            entry("Doe-2020a", "First"),
            "",
            entry("Doe-2020b", "Second"),
            ""
          )
        )
        # the sources are not rewritten, and bib.bib is not a source
        testthat::expect_equal(
          object = readLines(con = file.path(bib_dir, "a.bib")),
          expected = entry("Doe-2020a", "First")
        )
        suppressMessages(expr = Bib(path = root))
        testthat::expect_equal(
          object = readLines(con = file.path(bib_dir, "bib.bib")),
          expected = merged
        )
        testthat::expect_equal(
          object = readLines(
            con = file.path(root, ".setup", "quarto", "bib", "quarto.bib")
          ),
          expected = merged
        )
        testthat::expect_true(
          object = file.exists(file.path(root, "vignettes", "vignettes.bib"))
        )
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "copies an existing bib.bib without sources"),
      {
        root <- .TestProject()
        bib_dir <- file.path(root, ".setup", "latex", "bib")
        dir.create(path = bib_dir, recursive = TRUE)
        dir.create(path = file.path(root, ".setup", "quarto"))
        dir.create(path = file.path(root, "vignettes"))
        merged <- c(entry("Doe-2020a", "First"), "")
        writeLines(text = merged, con = file.path(bib_dir, "bib.bib"))
        testthat::expect_silent(object = out <- Bib(path = root))
        testthat::expect_equal(
          object = out,
          expected = file.path(bib_dir, "bib.bib")
        )
        testthat::expect_equal(
          object = readLines(con = file.path(bib_dir, "bib.bib")),
          expected = merged
        )
        testthat::expect_equal(
          object = readLines(
            con = file.path(root, ".setup", "quarto", "bib", "quarto.bib")
          ),
          expected = merged
        )
        testthat::expect_equal(
          object = readLines(
            con = file.path(root, "vignettes", "vignettes.bib")
          ),
          expected = merged
        )
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "says so when there are no .bib files"),
      {
        root <- .TestProject()
        testthat::expect_message(
          object = out <- Bib(path = root),
          regexp = "No \".bib\" files found"
        )
        testthat::expect_null(object = out)
        dir.create(
          path = file.path(root, ".setup", "latex", "bib"),
          recursive = TRUE
        )
        testthat::expect_message(
          object = Bib(path = root),
          regexp = "No \".bib\" files found"
        )
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-bib"
)
