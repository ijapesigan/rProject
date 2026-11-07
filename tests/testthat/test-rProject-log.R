## ---- test-rProject-log
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_if(condition = Sys.which(names = "git") == "")
    write <- function(root, file, text) {
      dir.create(
        path = dirname(path = file.path(root, file)),
        showWarnings = FALSE,
        recursive = TRUE
      )
      writeLines(text = text, con = file.path(root, file))
    }
    root <- tempfile(pattern = "log")
    path <- file.path(root, "proj")
    private <- file.path(path, ".verify")
    # the private repository has foo.R and old.R
    write(root = private, file = "R/foo.R", text = "Foo <- function() 1")
    write(root = private, file = "R/old.R", text = "Old <- function() 1")
    # neither is a deletion, though both are missing locally
    write(root = private, file = ".setup/repo/private.md", text = "owner/repo")
    write(root = private, file = ".setup/todo/todo.txt", text = "TODO")
    # marks are uploaded; other figures are generated
    write(root = path, file = ".setup/latex/figures/psu/mark.txt", text = "m")
    write(root = path, file = ".setup/latex/figures/pdf/plot.txt", text = "p")
    write(root = path, file = ".setup/todo/local.txt", text = "the user's")
    # gone.R was deleted locally
    write(root = private, file = "R/gone.R", text = "Gone <- function() 1")
    system2(
      command = "git",
      args = c("-C", shQuote(string = private), "init", "-q"),
      stdout = FALSE,
      stderr = FALSE
    )
    # locally foo.R changed and bar.R is new
    write(root = path, file = "R/foo.R", text = "Foo <- function() 2")
    write(root = path, file = "R/old.R", text = "Old <- function() 1")
    write(root = path, file = "R/bar.R", text = "Bar <- function() 1")
    write(root = path, file = "NAMESPACE", text = "export(Foo)")
    write(
      root = path,
      file = file.path(".setup", "ai", "specs", "2026-01-01-topic.md"),
      text = "# Spec: topic"
    )
    log_file <- suppressMessages(
      expr = Log(
        path = path,
        topic = "topic",
        summary = "rProject 9.9.9: a summary"
      )
    )
    log <- basename(path = log_file)
    lines <- readLines(con = log_file)
    section <- .VerifyLogFiles(log_file = log_file, project = "proj")
    testthat::test_that(
      desc = paste(text, "writes the template"),
      code = {
        testthat::expect_true(object = "rProject 9.9.9: a summary" %in% lines)
        testthat::expect_true(
          object = paste0("Log: .setup/logs/", log) %in% lines
        )
        testthat::expect_true(object = "| (pending) | | |" %in% lines)
        testthat::expect_true(
          object = "Spec: .setup/ai/specs/2026-01-01-topic.md" %in% lines
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "lists new and edited files, skipping generated ones"),
      code = {
        upload <- section$file[section$action == "upload"]
        testthat::expect_true(
          object = all(
            c(
              "R/bar.R",
              "R/foo.R",
              file.path(".setup", "logs", log),
              file.path(".setup", "logs", "index.md")
            ) %in% upload
          )
        )
        testthat::expect_false(object = "R/old.R" %in% upload)
        testthat::expect_false(object = "NAMESPACE" %in% upload)
        testthat::expect_false(
          object = any(grepl(pattern = "^\\.verify", x = upload))
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "lists figures/psu/ and leaves out .setup/todo/"),
      code = {
        upload <- section$file[section$action == "upload"]
        testthat::expect_true(
          object = ".setup/latex/figures/psu/mark.txt" %in% upload
        )
        testthat::expect_false(
          object = ".setup/latex/figures/pdf/plot.txt" %in% upload
        )
        testthat::expect_false(
          object = any(grepl(pattern = "^\\.setup/todo/", x = upload))
        )
      }
    )
    testthat::test_that(
      desc = paste(
        text,
        "lists files deleted locally under Delete in Overleaf"
      ),
      code = {
        testthat::expect_equal(
          object = section$file[section$action == "delete"],
          expected = "R/gone.R"
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "adds a pending row to the index"),
      code = {
        index <- readLines(con = file.path(path, ".setup", "logs", "index.md"))
        testthat::expect_true(
          object = any(
            grepl(
              pattern = paste0("(pending) | ", log),
              x = index,
              fixed = TRUE
            )
          )
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "refuses to overwrite and updates the lists"),
      code = {
        testthat::expect_error(
          object = Log(path = path, topic = "topic"),
          regexp = "already exists"
        )
        write(root = path, file = "R/baz.R", text = "Baz <- function() 1")
        suppressMessages(
          expr = Log(path = path, topic = "topic", update = TRUE)
        )
        lines <- readLines(con = log_file)
        testthat::expect_true(object = "- R/baz.R" %in% lines)
        testthat::expect_true(object = "rProject 9.9.9: a summary" %in% lines)
        testthat::expect_equal(
          object = sum(lines == "## Files to update in Overleaf"),
          expected = 1L
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "writes TODO without a clone"),
      code = {
        other <- file.path(root, "other")
        dir.create(path = other)
        file <- suppressMessages(expr = Log(path = other, topic = "x"))
        testthat::expect_true(object = "- TODO" %in% readLines(con = file))
      }
    )
    unlink(x = root, recursive = TRUE)
  },
  text = "test-rProject-log"
)
