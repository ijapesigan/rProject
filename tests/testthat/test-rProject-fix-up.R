## ---- test-rProject-fix-up
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    path <- tempfile(pattern = "fixup")
    logs <- file.path(path, ".setup", "logs")
    dir.create(path = logs, recursive = TRUE)
    writeLines(
      text = c(
        "# index", "", "| Date | Commit | Log | Summary | Verified |",
        "|---|---|---|---|---|"
      ),
      con = file.path(logs, "index.md")
    )
    log <- suppressMessages(
      expr = {
        writeLines(
          text = c(
            "# t", "", "## Pushes", "", "| Date | Commit | Result |",
            "|---|---|---|", "| 2026-01-01 | abc1234 | ok |", "",
            "## Needs compute node", "", "- (none)"
          ),
          con = file.path(logs, "2026-01-01-topic.md")
        )
        FixUp(path = path, topic = "topic", summary = "Fix-up: x")
      }
    )
    lines <- readLines(con = log)
    index <- readLines(con = file.path(logs, "index.md"))
    testthat::test_that(
      desc = text,
      code = {
        testthat::expect_true(object = "## Fix-up: Fix-up: x" %in% lines)
        testthat::expect_true(
          object = "Log: .setup/logs/2026-01-01-topic.md" %in% lines
        )
        testthat::expect_true(
          object = "### Files to update in Overleaf" %in% lines
        )
        testthat::expect_equal(
          object = lines[8],
          expected = "|  | (pending) |  |"
        )
        testthat::expect_true(
          object = grepl(pattern = "\\(pending\\) .*topic.md", x = index[5])
        )
        testthat::expect_error(
          object = FixUp(path = path, topic = "none", summary = "x")
        )
      }
    )
  },
  text = "test-rProject-fix-up"
)
