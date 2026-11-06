## ---- test-rProject-ai-global-merge
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    root <- tempfile(pattern = "aiglobal")
    home <- tempfile(pattern = "home")
    source_dir <- file.path(root, ".setup", "ai", "global")
    dir.create(
      path = source_dir,
      recursive = TRUE
    )
    dir.create(
      path = file.path(home, ".claude"),
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
      expr = AIGlobal(
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
        testthat::expect_equal(object = merged$theme, expected = "dark")
      }
    )
    testthat::test_that(
      paste(text, "keeps other keys and rules"),
      {
        testthat::expect_true(object = merged$autoMode)
        testthat::expect_equal(
          object = unlist(x = merged$permissions$allow),
          expected = "mcp__undermind"
        )
        testthat::expect_equal(
          object = unlist(x = merged$permissions$deny),
          expected = c("Read(**/*secrets*)", "Read(~/.x)")
        )
        testthat::expect_true(
          object = any(
            grepl(
              pattern = "\"env\": \\{\\}",
              x = readLines(con = file.path(home, ".claude", "settings.json"))
            )
          )
        )
      }
    )
    testthat::test_that(
      paste(text, "is stable"),
      {
        testthat::expect_null(
          object = suppressMessages(
            expr = AIGlobal(
              path = root,
              home = home
            )
          )
        )
      }
    )
    unlink(
      x = c(root, home),
      recursive = TRUE
    )
  },
  text = "test-rProject-ai-global-merge"
)
