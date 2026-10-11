## ---- test-rProject-size-check
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    root <- tempfile(pattern = "sizecheck")
    dir.create(file.path(root, ".setup", "data-raw"), recursive = TRUE)
    dir.create(file.path(root, ".library"), recursive = TRUE)
    status <- function(checks, check) {
      checks$status[checks$check == check]
    }
    # small text files only
    writeLines(
      text = "Foo <- function() 1",
      con = file.path(root, "foo.R")
    )
    checks <- suppressMessages(SizeCheck(path = root))
    testthat::test_that(
      paste(text, "passes a small project"),
      {
        testthat::expect_true(all(checks$status == "pass"))
      }
    )
    # a 1.5 MB text file twice, a binary file, and a big file in .library
    big_text <- paste(rep(strrep("a", 99), 15000), collapse = "\n")
    for (file in c("data.txt", "copy.txt")) {
      writeLines(
        text = big_text,
        con = file.path(root, ".setup", "data-raw", file)
      )
    }
    writeBin(
      object = as.raw(c(0, rep(1, 2e6))),
      con = file.path(root, "data.rds")
    )
    writeLines(
      text = big_text,
      con = file.path(root, ".library", "skip.txt")
    )
    checks <- suppressMessages(
      SizeCheck(
        path = root,
        editable = 2,
        text_file = 1,
        file = 1.8,
        total = 3,
        files = 3L
      )
    )
    testthat::test_that(
      paste(text, "fails over each limit"),
      {
        testthat::expect_equal(status(checks, "Editable text"), "fail")
        testthat::expect_equal(status(checks, "Text file size"), "fail")
        testthat::expect_equal(status(checks, "File size"), "fail")
        testthat::expect_match(
          checks$detail[checks$check == "File size"],
          "data.rds"
        )
        testthat::expect_equal(status(checks, "Number of files"), "fail")
        testthat::expect_equal(status(checks, "Total size"), "warn")
      }
    )
    testthat::test_that(
      paste(text, "finds duplicates and skips local folders"),
      {
        testthat::expect_equal(status(checks, "Duplicates"), "warn")
        testthat::expect_match(
          checks$detail[checks$check == "Duplicates"],
          "copy.txt = .setup/data-raw/data.txt",
          fixed = TRUE
        )
        testthat::expect_false(
          grepl("skip.txt", checks$detail[checks$check == "Duplicates"])
        )
        testthat::expect_match(
          checks$detail[checks$check == "Number of files"],
          "^4 files"
        )
      }
    )
    testthat::test_that(
      paste(text, "stops when asked"),
      {
        testthat::expect_error(
          suppressMessages(
            SizeCheck(path = root, editable = 2, error = TRUE)
          ),
          "Editable text"
        )
      }
    )
    unlink(root, recursive = TRUE)
  },
  text = "test-rProject-size-check"
)
