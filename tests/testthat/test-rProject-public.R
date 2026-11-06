## ---- test-rProject-public
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_if(condition = Sys.which(names = "git") == "")
    write <- function(root, file, text) {
      dir.create(
        path = dirname(path = file.path(root, file)),
        showWarnings = FALSE,
        recursive = TRUE
      )
      writeLines(text = text, con = file.path(root, file))
    }
    root <- tempfile(pattern = "public")
    dir.create(path = root)
    system2(
      command = "git",
      args = c("-C", shQuote(string = root), "init", "-q"),
      stdout = FALSE,
      stderr = FALSE
    )
    write(
      root = root,
      file = ".gitignore",
      text = c(".setup/ai/", "*secrets*")
    )
    write(root = root, file = "R/foo.R", text = "Foo <- function() 1")
    write(root = root, file = ".setup/ai/plan.md", text = "private plan")
    token <- paste0("ghp_", strrep(x = "a", times = 36))
    # a token in an ignored file is never published
    write(
      root = root,
      file = ".setup/scripts/secrets.R",
      text = paste0("x <- \"", token, "\"")
    )
    testthat::test_that(
      paste(text, "passes a safe export"),
      {
        testthat::skip_on_os(os = "windows")
        exported <- suppressMessages(expr = Public(path = root))
        testthat::expect_true(object = "R/foo.R" %in% exported)
        testthat::expect_false(object = ".setup/ai/plan.md" %in% exported)
      }
    )
    testthat::test_that(
      paste(text, "stops on a private file in the export"),
      {
        write(root = root, file = ".gitignore", text = "*secrets*")
        testthat::expect_error(
          object = suppressMessages(expr = Public(path = root)),
          regexp = ".setup/ai/plan.md (private)",
          fixed = TRUE
        )
      }
    )
    testthat::test_that(
      paste(text, "stops on a token in a published file"),
      {
        write(
          root = root,
          file = ".gitignore",
          text = c(".setup/ai/", "*secrets*")
        )
        write(
          root = root,
          file = "R/token.R",
          text = paste0("x <- \"", token, "\"")
        )
        testthat::expect_error(
          object = suppressMessages(expr = Public(path = root)),
          regexp = "R/token.R:1 (github)",
          fixed = TRUE
        )
      }
    )
    unlink(x = root, recursive = TRUE)
    # a folder that is not a git repository (e.g., downloaded from Overleaf)
    root <- tempfile(pattern = "public-nogit")
    write(root = root, file = ".gitignore", text = ".setup/ai/")
    write(root = root, file = "R/foo.R", text = "Foo <- function() 1")
    write(root = root, file = ".setup/ai/plan.md", text = "private plan")
    write(root = root, file = ".setup/repo/.gitignore", text = c("*", "*/"))
    write(
      root = root,
      file = ".setup/repo/private-github.md",
      text = "owner/repo"
    )
    testthat::test_that(
      paste(text, "applies .gitignore outside a git repository"),
      {
        testthat::skip_on_os(os = "windows")
        exported <- suppressMessages(expr = Public(path = root))
        testthat::expect_true(object = "R/foo.R" %in% exported)
        testthat::expect_false(object = ".setup/ai/plan.md" %in% exported)
        testthat::expect_false(
          object = ".setup/repo/private-github.md" %in% exported
        )
        testthat::expect_false(
          object = dir.exists(paths = file.path(root, ".git"))
        )
      }
    )
    testthat::test_that(
      paste(text, "stops on .setup/todo in the export"),
      {
        testthat::skip_on_os(os = "windows")
        write(root = root, file = ".setup/todo/todo.txt", text = "1. an item")
        testthat::expect_error(
          object = suppressMessages(expr = Public(path = root)),
          regexp = ".setup/todo/todo.txt (private)",
          fixed = TRUE
        )
        unlink(x = file.path(root, ".setup", "todo"), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "stops on .setup/repo in the export"),
      {
        testthat::skip_on_os(os = "windows")
        unlink(x = file.path(root, ".setup", "repo", ".gitignore"))
        testthat::expect_error(
          object = suppressMessages(expr = Public(path = root)),
          regexp = ".setup/repo/private-github.md (private)",
          fixed = TRUE
        )
      }
    )
    unlink(x = root, recursive = TRUE)
  },
  text = "test-rProject-public"
)
