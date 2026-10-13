## ---- test-rProject-log
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_if(Sys.which("git") == "")
    write <- function(root, file, text) {
      dir.create(
        dirname(file.path(root, file)),
        showWarnings = FALSE,
        recursive = TRUE
      )
      writeLines(text = text, con = file.path(root, file))
    }
    root <- tempfile(pattern = "log")
    path <- file.path(root, "proj")
    private <- file.path(path, ".verify")
    # the private repository has foo.R and old.R
    write(private, "R/foo.R", "Foo <- function() 1")
    write(private, "R/old.R", "Old <- function() 1")
    # gone.R was deleted locally
    write(private, "R/gone.R", "Gone <- function() 1")
    system2(
      command = "git",
      args = c("-C", shQuote(private), "init", "-q"),
      stdout = FALSE,
      stderr = FALSE
    )
    # locally foo.R changed and bar.R is new
    write(path, "R/foo.R", "Foo <- function() 2")
    write(path, "R/old.R", "Old <- function() 1")
    write(path, "R/bar.R", "Bar <- function() 1")
    write(path, "NAMESPACE", "export(Foo)")
    write(
      path,
      file.path(".setup", "ai", "specs", "2026-01-01-topic.md"),
      "# Spec: topic"
    )
    log_file <- suppressMessages(
      Log(
        path = path,
        topic = "topic",
        summary = "rProject 9.9.9: a summary"
      )
    )
    log <- basename(log_file)
    lines <- readLines(log_file)
    section <- .VerifyLogFiles(log_file = log_file, project = "proj")
    testthat::test_that(
      paste(text, "writes the template"),
      {
        testthat::expect_true("rProject 9.9.9: a summary" %in% lines)
        testthat::expect_true(paste0("Log: .setup/logs/", log) %in% lines)
        testthat::expect_true("| (pending) | | |" %in% lines)
        testthat::expect_true(
          "Spec: .setup/ai/specs/2026-01-01-topic.md" %in% lines
        )
      }
    )
    testthat::test_that(
      paste(text, "lists new and edited files, skipping generated ones"),
      {
        upload <- section$file[section$action == "upload"]
        testthat::expect_true(
          all(
            c(
              "R/bar.R",
              "R/foo.R",
              file.path(".setup", "logs", log),
              file.path(".setup", "logs", "index.md")
            ) %in% upload
          )
        )
        testthat::expect_false("R/old.R" %in% upload)
        testthat::expect_false("NAMESPACE" %in% upload)
        testthat::expect_false(any(grepl("^\\.verify", upload)))
      }
    )
    testthat::test_that(
      paste(text, "lists files deleted locally under Delete in Overleaf"),
      {
        testthat::expect_equal(
          section$file[section$action == "delete"],
          "R/gone.R"
        )
      }
    )
    testthat::test_that(
      paste(text, "adds a pending row to the index"),
      {
        index <- readLines(file.path(path, ".setup", "logs", "index.md"))
        testthat::expect_true(
          any(grepl(paste0("(pending) | ", log), index, fixed = TRUE))
        )
      }
    )
    testthat::test_that(
      paste(text, "refuses to overwrite and updates the lists"),
      {
        testthat::expect_error(
          Log(path = path, topic = "topic"),
          "already exists"
        )
        write(path, "R/baz.R", "Baz <- function() 1")
        suppressMessages(Log(path = path, topic = "topic", update = TRUE))
        lines <- readLines(log_file)
        testthat::expect_true("- R/baz.R" %in% lines)
        testthat::expect_true("rProject 9.9.9: a summary" %in% lines)
        testthat::expect_equal(
          sum(lines == "## Files to update in Overleaf"),
          1L
        )
      }
    )
    testthat::test_that(
      paste(text, "writes TODO without a clone"),
      {
        other <- file.path(root, "other")
        dir.create(other)
        file <- suppressMessages(Log(path = other, topic = "x"))
        testthat::expect_true("- TODO" %in% readLines(file))
      }
    )
    unlink(root, recursive = TRUE)
  },
  text = "test-rProject-log"
)
