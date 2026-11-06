## ---- test-rProject-size-check
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    root <- tempfile(pattern = "sizecheck")
    dir.create(path = file.path(root, ".setup", "data-raw"), recursive = TRUE)
    dir.create(path = file.path(root, ".library"), recursive = TRUE)
    status <- function(checks, check) {
      checks$status[checks$check == check]
    }
    # small text files only
    writeLines(
      text = "Foo <- function() 1",
      con = file.path(root, "foo.R")
    )
    checks <- suppressMessages(expr = SizeCheck(path = root))
    testthat::test_that(
      paste(text, "passes a small project"),
      {
        testthat::expect_true(object = all(checks$status == "pass"))
      }
    )
    # a 1.5 MB text file twice, a binary file, and a big file in .library
    big_text <- paste(
      rep(x = strrep(x = "a", times = 99), 15000),
      collapse = "\n"
    )
    for (file in c("data.txt", "copy.txt")) {
      writeLines(
        text = big_text,
        con = file.path(root, ".setup", "data-raw", file)
      )
    }
    writeBin(
      object = as.raw(x = c(0, rep(x = 1, 2e6))),
      con = file.path(root, "data.rds")
    )
    writeLines(
      text = big_text,
      con = file.path(root, ".library", "skip.txt")
    )
    checks <- suppressMessages(
      expr = SizeCheck(
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
        testthat::expect_equal(
          object = status(checks, "Editable text"),
          expected = "fail"
        )
        testthat::expect_equal(
          object = status(checks, "Text file size"),
          expected = "fail"
        )
        testthat::expect_equal(
          object = status(checks, "File size"),
          expected = "fail"
        )
        testthat::expect_match(
          object = checks$detail[checks$check == "File size"],
          regexp = "data.rds"
        )
        testthat::expect_equal(
          object = status(checks, "Number of files"),
          expected = "fail"
        )
        testthat::expect_equal(
          object = status(checks, "Total size"),
          expected = "warn"
        )
      }
    )
    testthat::test_that(
      paste(text, "finds duplicates and skips local folders"),
      {
        testthat::expect_equal(
          object = status(checks, "Duplicates"),
          expected = "warn"
        )
        testthat::expect_match(
          object = checks$detail[checks$check == "Duplicates"],
          regexp = "copy.txt = .setup/data-raw/data.txt",
          fixed = TRUE
        )
        testthat::expect_false(
          object = grepl(
            pattern = "skip.txt",
            x = checks$detail[checks$check == "Duplicates"]
          )
        )
        testthat::expect_match(
          object = checks$detail[checks$check == "Number of files"],
          regexp = "^4 files"
        )
      }
    )
    testthat::test_that(
      paste(text, "stops when asked"),
      {
        testthat::expect_error(
          object = suppressMessages(
            expr = SizeCheck(path = root, editable = 2, error = TRUE)
          ),
          regexp = "Editable text"
        )
      }
    )
    unlink(x = root, recursive = TRUE)
  },
  text = "test-rProject-size-check"
)
