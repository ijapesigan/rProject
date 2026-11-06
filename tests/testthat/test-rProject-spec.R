## ---- test-rProject-spec
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    root <- tempfile(pattern = "spec")
    dir.create(path = root)
    file <- suppressMessages(
      expr = Spec(
        path = root,
        topic = "new-thing",
        title = "A new thing"
      )
    )
    testthat::test_that(
      paste(text, "writes the template"),
      {
        lines <- readLines(con = file)
        testthat::expect_equal(
          object = basename(path = file),
          expected = paste0(format(x = Sys.Date()), "-new-thing.md")
        )
        testthat::expect_equal(
          object = lines[1],
          expected = "# Spec: A new thing"
        )
        testthat::expect_true(
          object = all(
            c("## Problem", "## Design", "## Files", "## Acceptance") %in%
              lines
          )
        )
      }
    )
    testthat::test_that(
      paste(text, "does not overwrite"),
      {
        testthat::expect_error(
          object = Spec(path = root, topic = "new-thing"),
          regexp = "already exists"
        )
      }
    )
    unlink(x = root, recursive = TRUE)
  },
  text = "test-rProject-spec"
)
