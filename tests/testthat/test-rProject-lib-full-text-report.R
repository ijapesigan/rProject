## ---- test-rProject-lib-full-text-report
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    repo <- "lib-2000-2009-article"
    entry <- function(root, key) {
      dir <- file.path(root, ".setup", "latex", "bib")
      dir.create(path = dir, showWarnings = FALSE, recursive = TRUE)
      writeLines(
        text = "@Article{x,}",
        con = file.path(dir, paste0(repo, "-", key, ".bib"))
      )
    }
    note <- function(root, folder, name) {
      dir <- file.path(root, ".setup", "notes", folder)
      dir.create(path = dir, showWarnings = FALSE, recursive = TRUE)
      writeLines(text = "x", con = file.path(dir, name))
    }
    fixture <- function() {
      work <- tempfile(pattern = "lib")
      root <- file.path(work, repo, ".verify")
      dir.create(path = root, recursive = TRUE)
      keys <- c(
        "Whole-2000", "Part-2001", "Book-2002", "Short-2008", "Short-2008a",
        "None-2003", "Docx-2004", "Suppl-2005", "Exempt-2006"
      )
      for (key in keys) {
        entry(root = root, key = key)
      }
      note(root, "pdf", paste0(repo, "-Whole-2000.pdf"))
      note(root, "pdf", paste0(repo, "-Part-2001-ch01.pdf"))
      note(root, "epub", paste0(repo, "-Book-2002.epub"))
      # the key -2008a does not give -2008 its full text
      note(root, "pdf", paste0(repo, "-Short-2008a.pdf"))
      note(root, "docx", paste0(repo, "-Docx-2004.docx"))
      note(root, "pdf", paste0(repo, "-Suppl-2005-supplement.pdf"))
      note(root, "pdf", paste0(repo, "-Misspelled-2007.pdf"))
      writeLines(
        text = c("Exempt-2006 # out of print", ""),
        con = file.path(root, ".setup", "notes", "no-full-text.txt")
      )
      list(work = work, root = root)
    }
    x <- fixture()
    out <- .LibFullText(path = x$root, private = x$root)
    status <- function(key) {
      out$entries$status[out$entries$key == key]
    }
    testthat::test_that(
      desc = paste(text, "finds whole works, parts, and EPUBs"),
      code = {
        for (key in c("Whole-2000", "Part-2001", "Book-2002", "Short-2008a")) {
          testthat::expect_identical(object = status(key), expected = "ok")
        }
      }
    )
    testthat::test_that(
      desc = paste(text, "does not match a longer key"),
      code = {
        testthat::expect_identical(
          object = status("Short-2008"),
          expected = "missing"
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "treats docx, supplements, and exemptions as decided"),
      code = {
        testthat::expect_identical(
          object = status("Docx-2004"),
          expected = "docx only: convert to PDF"
        )
        testthat::expect_identical(
          object = status("Suppl-2005"),
          expected = "missing"
        )
        testthat::expect_identical(
          object = status("Exempt-2006"),
          expected = "exempt"
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "lists files that match no entry"),
      code = {
        testthat::expect_identical(
          object = out$orphans,
          expected = paste0(repo, "-Misspelled-2007.pdf")
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "reports across projects"),
      code = {
        dir.create(path = file.path(x$work, "lib-2010-2019-book"))
        report <- suppressMessages(expr = LibFullTextReport(root = x$work))
        testthat::expect_setequal(
          object = report$missing$key,
          expected = c("Short-2008", "None-2003", "Docx-2004", "Suppl-2005")
        )
        testthat::expect_identical(
          object = report$orphans$file,
          expected = paste0(repo, "-Misspelled-2007.pdf")
        )
        testthat::expect_identical(
          object = report$unchecked,
          expected = "lib-2010-2019-book"
        )
      }
    )
    unlink(x = x$work, recursive = TRUE)
  },
  text = "test-rProject-lib-full-text-report"
)
