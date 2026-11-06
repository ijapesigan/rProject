## ---- test-rProject-ai-global-agents
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::test_that(
      desc = paste(text, "installs agents, and removes only those that left"),
      code = {
        root <- tempfile(pattern = "aiglobal")
        home <- tempfile(pattern = "home")
        on.exit(expr = unlink(x = c(root, home), recursive = TRUE), add = TRUE)
        dir.create(path = file.path(root, ".setup", "ai", "global"), recursive = TRUE)
        agents <- file.path(root, "inst", "ai", "agents")
        dir.create(path = agents, recursive = TRUE)
        writeLines(text = "# Global", con = file.path(root, ".setup", "ai", "global", "AGENTS.md"))
        writeLines(text = "a", con = file.path(agents, "one.md"))
        writeLines(text = "b", con = file.path(agents, "two.md"))
        suppressMessages(expr = AIGlobal(path = root, home = home))
        installed <- file.path(home, ".claude", "agents")
        testthat::expect_true(object = all(file.exists(file.path(installed, c("one.md", "two.md")))))
        writeLines(text = "mine", con = file.path(installed, "mine.md"))
        unlink(x = file.path(agents, "two.md"))
        suppressMessages(expr = AIGlobal(path = root, home = home))
        testthat::expect_false(object = file.exists(file.path(installed, "two.md")))
        testthat::expect_true(object = file.exists(file.path(installed, "mine.md")))
        testthat::expect_true(object = file.exists(file.path(installed, "one.md")))
      }
    )
    testthat::test_that(
      desc = paste(text, "gives each agent a name, a model, and a description"),
      code = {
        files <- list.files(
          path = testthat::test_path("..", "..", "inst", "ai", "agents"),
          pattern = "\\.md$",
          full.names = TRUE
        )
        testthat::skip_if(condition = length(x = files) == 0)
        for (file in files) {
          lines <- readLines(con = file, warn = FALSE)
          testthat::expect_true(
            object = paste0("name: ", sub(pattern = "\\.md$", replacement = "", x = basename(path = file))) %in% lines
          )
          testthat::expect_true(object = any(grepl(pattern = "^model: (haiku|sonnet)$", x = lines)))
          testthat::expect_true(object = any(grepl(pattern = "^description: ", x = lines)))
        }
      }
    )
  },
  text = "test-rProject-ai-global-agents"
)
