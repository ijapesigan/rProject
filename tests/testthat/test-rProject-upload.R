## ---- test-rProject-upload
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    root <- tempfile(pattern = "upload")
    path <- file.path(root, "proj")
    logs <- file.path(path, ".setup", "logs")
    dir.create(path = logs, recursive = TRUE)
    dir.create(path = file.path(path, "R"))
    writeLines(text = "a", con = file.path(path, "R", "a.R"))
    writeLines(text = "b", con = file.path(path, "R", "b.R"))
    writeLines(
      text = c(
        "# t", "", "## Commit message (paste only the block below)", "",
        "```", "Change set", "", "Log: .setup/logs/2026-01-01-topic.md", "```",
        "", "## Files to update in Overleaf", "", "### New", "- R/a.R", "",
        "### Delete in Overleaf", "- R/gone.R", "",
        "## Fix-up: Fix-up: b", "", "```", "Fix-up: b", "```", "",
        "### Files to update in Overleaf", "", "#### Edited", "- R/b.R"
      ),
      con = file.path(logs, "2026-01-01-topic.md")
    )
    dest <- file.path(root, "upload")
    first <- suppressMessages(
      expr = Upload(path = path, topic = "topic", dest = dest)
    )
    second <- suppressMessages(
      expr = Upload(path = path, topic = "topic", fixup = TRUE, dest = dest)
    )
    testthat::test_that(
      desc = text,
      code = {
        testthat::expect_true(object = file.exists(file.path(first, "R/a.R")))
        testthat::expect_false(object = file.exists(file.path(first, "R/b.R")))
        testthat::expect_true(object = file.exists(file.path(second, "R/b.R")))
        testthat::expect_false(object = file.exists(file.path(second, "R/a.R")))
        testthat::expect_true(object = grepl(pattern = "-fixup$", x = second))
        testthat::expect_error(
          object = Upload(path = path, topic = "topic", dest = dest)
        )
      }
    )
  },
  text = "test-rProject-upload"
)
