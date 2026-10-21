## ---- test-rProject-ai-global-merge
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    root <- tempfile(pattern = "aiglobal")
    home <- tempfile(pattern = "home")
    source_dir <- file.path(root, ".setup", "ai", "global")
    dir.create(
      source_dir,
      recursive = TRUE
    )
    dir.create(
      file.path(home, ".claude"),
      recursive = TRUE
    )
    writeLines(
      text = "# Global",
      con = file.path(source_dir, "AGENTS.md")
    )
    writeLines(
      text = paste0(
        "{\"theme\": \"dark\", \"permissions\": ",
        "{\"deny\": [\"Read(**/*secrets*)\"]}}"
      ),
      con = file.path(source_dir, "claude-settings.json")
    )
    writeLines(
      text = paste0(
        "{\"theme\": \"light\", \"autoMode\": true, \"env\": {}, ",
        "\"permissions\": {\"allow\": [\"mcp__undermind\"], ",
        "\"deny\": [\"Read(**/*secrets*)\", \"Read(~/.x)\"]}}"
      ),
      con = file.path(home, ".claude", "settings.json")
    )
    suppressMessages(
      AIGlobal(
        path = root,
        home = home
      )
    )
    merged <- jsonlite::fromJSON(
      txt = file.path(home, ".claude", "settings.json"),
      simplifyVector = FALSE
    )
    testthat::test_that(
      paste(text, "source keys win"),
      {
        testthat::expect_equal(merged$theme, "dark")
      }
    )
    testthat::test_that(
      paste(text, "keeps other keys and rules"),
      {
        testthat::expect_true(merged$autoMode)
        testthat::expect_equal(
          unlist(merged$permissions$allow),
          "mcp__undermind"
        )
        testthat::expect_equal(
          unlist(merged$permissions$deny),
          c("Read(**/*secrets*)", "Read(~/.x)")
        )
        testthat::expect_true(
          any(
            grepl(
              pattern = "\"env\": \\{\\}",
              x = readLines(file.path(home, ".claude", "settings.json"))
            )
          )
        )
      }
    )
    testthat::test_that(
      paste(text, "is stable"),
      {
        testthat::expect_null(
          suppressMessages(
            AIGlobal(
              path = root,
              home = home
            )
          )
        )
      }
    )
    unlink(
      c(root, home),
      recursive = TRUE
    )
  },
  text = "test-rProject-ai-global-merge"
)
