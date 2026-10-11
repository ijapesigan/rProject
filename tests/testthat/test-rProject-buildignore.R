## ---- test-rProject-buildignore
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    root <- tempfile(pattern = "buildignore")
    dir.create(root)
    writeLines(
      text = "Package: test",
      con = file.path(root, "DESCRIPTION")
    )
    BuildIgnore(
      path = root,
      project = "test",
      add = "^extra$"
    )
    patterns <- readLines(file.path(root, ".Rbuildignore"))
    ai_files <- c(
      ".claude",
      "CLAUDE.md",
      "CLAUDE.local.md",
      ".mcp.json",
      "AGENTS.md",
      ".codex",
      "GEMINI.md",
      ".gemini",
      ".github"
    )
    ignored <- function(file) {
      any(
        vapply(
          X = patterns,
          FUN = function(pattern) {
            grepl(
              pattern = pattern,
              x = file
            )
          },
          FUN.VALUE = logical(1)
        )
      )
    }
    testthat::test_that(
      paste(text, "ignores AI tool files"),
      {
        testthat::expect_true(
          all(
            vapply(
              X = ai_files,
              FUN = ignored,
              FUN.VALUE = logical(1)
            )
          )
        )
      }
    )
    testthat::test_that(
      paste(text, "keeps package files"),
      {
        testthat::expect_false(
          any(
            vapply(
              X = c("DESCRIPTION", "NAMESPACE", "R", "man", "tests"),
              FUN = ignored,
              FUN.VALUE = logical(1)
            )
          )
        )
      }
    )
    testthat::test_that(
      paste(text, "appends add"),
      {
        testthat::expect_equal(
          utils::tail(patterns, 1),
          "^extra$"
        )
      }
    )
    unlink(
      root,
      recursive = TRUE
    )
  },
  text = "test-rProject-buildignore"
)
