## ---- test-rProject-verify-record-dot
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    setup <- function(log_lines, index_lines) {
      path <- tempfile(pattern = "record")
      logs <- file.path(path, ".setup", "logs")
      dir.create(path = logs, recursive = TRUE)
      writeLines(text = log_lines, con = file.path(logs, "2026-01-01-x.md"))
      writeLines(text = index_lines, con = file.path(logs, "index.md"))
      path
    }
    read <- function(path, file) {
      readLines(con = file.path(path, ".setup", "logs", file), warn = FALSE)
    }
    index_head <- c(
      "| Date | Commit | Log | Summary | Verified |",
      "|---|---|---|---|---|"
    )
    # template header and an empty last cell
    path <- setup(
      log_lines = c(
        "## Pushes", "", "| Commit | Date | Result |", "|---|---|---|",
        "| (pending) | | |"
      ),
      index_lines = c(
        index_head, "| 2026-01-01 | (pending) | 2026-01-01-x.md | s | |"
      )
    )
    .VerifyRecord(
      path = path, log = "2026-01-01-x.md", sha = "abc1234", result = "ok"
    )
    log <- read(path = path, file = "2026-01-01-x.md")
    index <- read(path = path, file = "index.md")
    testthat::test_that(
      desc = text,
      code = {
        testthat::expect_true(
          object = grepl(
            pattern = "^\\| abc1234 \\| .* \\| ok \\|$",
            x = log[5]
          )
        )
        testthat::expect_equal(
          object = index[3],
          expected = "| 2026-01-01 | abc1234 | 2026-01-01-x.md | s | ok |"
        )
      }
    )
    # reordered header, a hand-written pending row, a non-empty last cell
    path <- setup(
      log_lines = c(
        "## Pushes", "", "| Date | Commit | Result |", "|---|---|---|",
        "| 2026-01-01 | (pending) | fix-up |"
      ),
      index_lines = c(
        index_head,
        "| 2026-01-01 | (pending) | 2026-01-01-x.md | s | not pushed |"
      )
    )
    .VerifyRecord(
      path = path, log = "2026-01-01-x.md", sha = "abc1234", result = "ok"
    )
    log <- read(path = path, file = "2026-01-01-x.md")
    index <- read(path = path, file = "index.md")
    testthat::test_that(
      desc = text,
      code = {
        testthat::expect_true(
          object = grepl(
            pattern = "^\\| .* \\| abc1234 \\| ok \\|$",
            x = log[5]
          )
        )
        testthat::expect_equal(
          object = length(x = log),
          expected = 5L
        )
        testthat::expect_equal(
          object = index[3],
          expected = "| 2026-01-01 | abc1234 | 2026-01-01-x.md | s | ok |"
        )
      }
    )
    # no pending row: a new row at the end, in the header's order
    path <- setup(
      log_lines = c(
        "## Pushes", "", "| Date | Commit | Result |", "|---|---|---|",
        "| 2026-01-01 | aaa1111 | ok |"
      ),
      index_lines = index_head
    )
    .VerifyRecord(
      path = path, log = "2026-01-01-x.md", sha = "abc1234", result = "ok"
    )
    log <- read(path = path, file = "2026-01-01-x.md")
    testthat::test_that(
      desc = text,
      code = {
        testthat::expect_equal(
          object = length(x = log),
          expected = 6L
        )
        testthat::expect_true(
          object = grepl(
            pattern = "^\\| .* \\| abc1234 \\| ok \\|$",
            x = log[6]
          )
        )
      }
    )
  },
  text = "test-rProject-verify-record-dot"
)
