## ---- test-rProject-spec
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    root <- tempfile(pattern = "spec")
    dir.create(root)
    file <- suppressMessages(
      Spec(
        path = root,
        topic = "new-thing",
        title = "A new thing"
      )
    )
    testthat::test_that(
      paste(text, "writes the template"),
      {
        lines <- readLines(file)
        testthat::expect_equal(
          basename(file),
          paste0(format(Sys.Date()), "-new-thing.md")
        )
        testthat::expect_equal(lines[1], "# Spec: A new thing")
        testthat::expect_true(
          all(
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
          Spec(path = root, topic = "new-thing"),
          "already exists"
        )
      }
    )
    unlink(root, recursive = TRUE)
  },
  text = "test-rProject-spec"
)
