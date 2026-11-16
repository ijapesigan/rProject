## ---- test-rProject-long-lines-dot
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    root <- tempfile()
    dir.create(path = file.path(root, "R"), recursive = TRUE)
    writeLines(
      text = c("x <- 1", paste0("# ", strrep(x = "a", times = 78))),
      con = file.path(root, "R", "edge.R")
    )
    writeLines(
      text = paste0("# ", strrep(x = "a", times = 80)),
      con = file.path(root, "R", "long.R")
    )
    writeLines(
      text = paste0("# ", strrep(x = "a", times = 90)),
      con = file.path(root, "R", "notes.md")
    )
    testthat::test_that(
      desc = paste(text, "finds lines over 80 characters in R files only"),
      code = {
        testthat::expect_identical(
          object = .LongLines(
            path = root,
            files = c("R/edge.R", "R/long.R", "R/notes.md", "R/gone.R")
          ),
          expected = "R/long.R:1"
        )
        testthat::expect_identical(
          object = .LongLines(
            path = root,
            files = character(length = 0L)
          ),
          expected = character(length = 0L)
        )
      }
    )
    unlink(x = root, recursive = TRUE)
  },
  text = "test-rProject-long-lines-dot"
)
