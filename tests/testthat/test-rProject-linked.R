## ---- test-rProject-linked
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    write <- function(root, file, lines) {
      dir.create(
        path = dirname(path = file.path(root, file)),
        showWarnings = FALSE,
        recursive = TRUE
      )
      writeLines(text = lines, con = file.path(root, file))
    }
    root <- tempfile(pattern = "linked")
    path <- file.path(root, "project")
    functions <- file.path(root, "functions")
    deps <- ".setup/r-dependencies/lib"
    write(path, file.path(deps, "lib-same.R"), "x <- 1")
    write(functions, "lib/lib-same.R", "x <- 1")
    write(path, file.path(deps, "lib-old.R"), "x <- 1")
    write(functions, "lib/lib-old.R", "x <- 2")
    write(path, file.path(deps, "lib-name.R"), "x <- 1")
    write(functions, "lib/lib-name-dot.R", "x <- 1")
    write(path, file.path(deps, "lib-gone.R"), "x <- 1")
    testthat::test_that(
      desc = paste(text, "reports the status of each file"),
      code = {
        out <- suppressMessages(expr = Linked(path = path))
        status <- stats::setNames(
          object = out$status,
          nm = basename(path = out$file)
        )
        testthat::expect_identical(
          object = status[["lib-same.R"]],
          expected = "same"
        )
        testthat::expect_identical(
          object = status[["lib-old.R"]],
          expected = "differs"
        )
        testthat::expect_identical(
          object = status[["lib-name.R"]],
          expected = "name differs"
        )
        testthat::expect_identical(
          object = status[["lib-gone.R"]],
          expected = "no source"
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "reads the clone from .setup/repo/functions.md"),
      code = {
        moved <- file.path(root, "elsewhere")
        file.rename(from = functions, to = moved)
        write(path, ".setup/repo/functions.md", moved)
        out <- suppressMessages(expr = Linked(path = path))
        testthat::expect_identical(object = nrow(x = out), expected = 4L)
        unlink(x = file.path(path, ".setup", "repo"), recursive = TRUE)
        file.rename(from = moved, to = functions)
      }
    )
    testthat::test_that(
      desc = paste(text, "stops without a clone"),
      code = {
        testthat::expect_error(
          object = Linked(path = path, functions = file.path(root, "none")),
          regexp = "No clone of the functions repository"
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "keeps linked files out of the upload lists in a log"),
      code = {
        testthat::skip_if(condition = Sys.which(names = "git") == "")
        private <- file.path(root, "private")
        dir.create(path = private)
        section <- .LogSection(
          path = path,
          private = private,
          log = "2026-01-01-topic.md"
        )
        start <- which(x = grepl(pattern = "^### Linked", x = section))
        testthat::expect_length(object = start, n = 1L)
        testthat::expect_true(
          object = paste0("- ", file.path(deps, "lib-old.R")) %in%
            section[seq(from = start, to = length(x = section))]
        )
        testthat::expect_false(
          object = paste0("- ", file.path(deps, "lib-old.R")) %in%
            section[seq_len(length.out = start - 1L)]
        )
      }
    )
    unlink(x = root, recursive = TRUE)
  },
  text = "test-rProject-linked"
)
