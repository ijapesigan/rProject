## ---- test-rProject-template-atomic
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::test_that(
      paste(text, "a running reader keeps the old file"),
      {
        target <- tempfile()
        writeLines(text = c("old 1", "old 2"), con = target)
        con <- file(description = target, open = "r")
        first <- readLines(con = con, n = 1L)
        .TemplateAtomic(target = target, text = c("new 1", "new 2", "new 3"))
        rest <- readLines(con = con)
        close(con = con)
        testthat::expect_identical(object = first, expected = "old 1")
        testthat::expect_identical(object = rest, expected = "old 2")
        testthat::expect_identical(
          object = readLines(con = target),
          expected = c("new 1", "new 2", "new 3")
        )
        unlink(x = target)
      }
    )
    testthat::test_that(
      paste(text, "copies a file, keeps the mode, and leaves no temporary"),
      {
        folder <- tempfile()
        dir.create(path = folder)
        target <- file.path(folder, "a.sh")
        from <- file.path(folder, "b")
        writeLines(text = "old", con = target)
        writeLines(text = "new", con = from)
        Sys.chmod(paths = target, mode = "755", use_umask = FALSE)
        .TemplateAtomic(target = target, from = from)
        testthat::expect_identical(
          object = readLines(con = target),
          expected = "new"
        )
        testthat::expect_identical(
          object = as.character(x = file.mode(target)),
          expected = "755"
        )
        testthat::expect_setequal(
          object = list.files(path = folder, all.files = TRUE, no.. = TRUE),
          expected = c("a.sh", "b")
        )
        unlink(x = folder, recursive = TRUE)
      }
    )
  },
  text = "test-rProject-template-atomic"
)
