## ---- test-rProject-lib-abstract-report
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    repo <- "lib-2000-2009-article"
    root <- tempfile(pattern = "lib")
    dir <- file.path(root, repo, ".setup", "latex", "bib")
    dir.create(path = dir, recursive = TRUE)
    put <- function(key, lines) {
      writeLines(
        text = lines,
        con = file.path(dir, paste0(repo, "-", key, ".bib"))
      )
    }
    put(
      key = "With-2000",
      lines = c("@Article{With-2000,", "  abstract = {x},", "}")
    )
    put(
      key = "Without-2001",
      lines = c("@Article{Without-2001,", "  title = {x},", "}")
    )
    put(
      key = "Book-2002",
      lines = c("@Book{Book-2002,", "  title = {x},", "}")
    )
    testthat::test_that(
      desc = paste(text, "lists only articles without an abstract"),
      code = {
        out <- suppressMessages(expr = LibAbstractReport(root = root))
        testthat::expect_identical(object = out$key, expected = "Without-2001")
        testthat::expect_identical(object = out$repo, expected = repo)
      }
    )
  },
  text = "test-rProject-lib-abstract-report"
)
