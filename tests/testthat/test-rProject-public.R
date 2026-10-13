## ---- test-rProject-public
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_if(Sys.which("git") == "")
    write <- function(root, file, text) {
      dir.create(
        dirname(file.path(root, file)),
        showWarnings = FALSE,
        recursive = TRUE
      )
      writeLines(text = text, con = file.path(root, file))
    }
    root <- tempfile(pattern = "public")
    dir.create(root)
    system2(
      command = "git",
      args = c("-C", shQuote(root), "init", "-q"),
      stdout = FALSE,
      stderr = FALSE
    )
    write(root, ".gitignore", c(".setup/ai/", "*secrets*"))
    write(root, "R/foo.R", "Foo <- function() 1")
    write(root, ".setup/ai/plan.md", "private plan")
    token <- paste0("ghp_", strrep("a", 36))
    # a token in an ignored file is never published
    write(root, ".setup/scripts/secrets.R", paste0("x <- \"", token, "\""))
    testthat::test_that(
      paste(text, "passes a safe export"),
      {
        testthat::skip_on_os("windows")
        exported <- suppressMessages(Public(path = root))
        testthat::expect_true("R/foo.R" %in% exported)
        testthat::expect_false(".setup/ai/plan.md" %in% exported)
      }
    )
    testthat::test_that(
      paste(text, "stops on a private file in the export"),
      {
        write(root, ".gitignore", "*secrets*")
        testthat::expect_error(
          suppressMessages(Public(path = root)),
          ".setup/ai/plan.md (private)",
          fixed = TRUE
        )
      }
    )
    testthat::test_that(
      paste(text, "stops on a token in a published file"),
      {
        write(root, ".gitignore", c(".setup/ai/", "*secrets*"))
        write(root, "R/token.R", paste0("x <- \"", token, "\""))
        testthat::expect_error(
          suppressMessages(Public(path = root)),
          "R/token.R:1 (github)",
          fixed = TRUE
        )
      }
    )
    unlink(root, recursive = TRUE)
    # a folder that is not a git repository (e.g., downloaded from Overleaf)
    root <- tempfile(pattern = "public-nogit")
    write(root, ".gitignore", ".setup/ai/")
    write(root, "R/foo.R", "Foo <- function() 1")
    write(root, ".setup/ai/plan.md", "private plan")
    write(root, ".setup/repo/.gitignore", c("*", "*/"))
    write(root, ".setup/repo/private-github.md", "owner/repo")
    testthat::test_that(
      paste(text, "applies .gitignore outside a git repository"),
      {
        testthat::skip_on_os("windows")
        exported <- suppressMessages(Public(path = root))
        testthat::expect_true("R/foo.R" %in% exported)
        testthat::expect_false(".setup/ai/plan.md" %in% exported)
        testthat::expect_false(".setup/repo/private-github.md" %in% exported)
        testthat::expect_false(dir.exists(file.path(root, ".git")))
      }
    )
    testthat::test_that(
      paste(text, "stops on .setup/repo in the export"),
      {
        testthat::skip_on_os("windows")
        unlink(file.path(root, ".setup", "repo", ".gitignore"))
        testthat::expect_error(
          suppressMessages(Public(path = root)),
          ".setup/repo/private-github.md (private)",
          fixed = TRUE
        )
      }
    )
    unlink(root, recursive = TRUE)
  },
  text = "test-rProject-public"
)
