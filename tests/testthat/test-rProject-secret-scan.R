## ---- test-rProject-secret-scan
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::test_that(
      desc = paste(text, "stops on a folder that does not exist"),
      code = {
        testthat::expect_error(
          object = SecretScan(path = tempfile(pattern = "missing")),
          regexp = "nothing was scanned"
        )
      }
    )
    # fake tokens are built at run time
    # so that this file does not trigger SecretScan or push protection
    fake_github <- paste0("ghp_", strrep(x = "a", times = 36))
    fake_codecov <- "00000000-0000-0000-0000-000000000000"
    root <- tempfile(pattern = "secretscan")
    dir.create(
      path = file.path(root, ".setup", "scripts"),
      recursive = TRUE
    )
    dir.create(
      path = file.path(root, ".library"),
      recursive = TRUE
    )
    writeLines(
      text = c(
        "tokens <- c(",
        paste0("  GITHUB_PAT = \"", fake_github, "\","),
        paste0("  CODECOV_TOKEN = \"", fake_codecov, "\""),
        ")"
      ),
      con = file.path(root, ".setup", "scripts", "secrets.R")
    )
    writeLines(
      text = paste0("GITHUB_PAT=", fake_github),
      con = file.path(root, ".Renviron")
    )
    writeLines(
      text = fake_github,
      con = file.path(root, ".library", "skip.txt")
    )
    writeLines(
      text = "x <- 1",
      con = file.path(root, "clean.R")
    )
    testthat::test_that(
      desc = paste(text, "finds secrets"),
      code = {
        testthat::expect_error(
          object = SecretScan(path = root)
        )
        findings <- suppressWarnings(
          expr = SecretScan(path = root, error = FALSE)
        )
        testthat::expect_equal(
          object = sort(x = findings$type),
          expected = c("codecov", "github")
        )
        testthat::expect_true(
          object = all(findings$file == ".setup/scripts/secrets.R")
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "masks values"),
      code = {
        findings <- suppressWarnings(
          expr = SecretScan(path = root, error = FALSE)
        )
        testthat::expect_false(
          object = any(
            grepl(pattern = fake_github, x = findings$match, fixed = TRUE)
          )
        )
        msg <- tryCatch(
          expr = SecretScan(path = root),
          error = function(e) {
            conditionMessage(c = e)
          }
        )
        testthat::expect_false(
          object = grepl(pattern = fake_github, x = msg, fixed = TRUE)
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "passes when clean"),
      code = {
        unlink(x = file.path(root, ".setup", "scripts", "secrets.R"))
        findings <- suppressMessages(
          expr = SecretScan(path = root)
        )
        testthat::expect_equal(
          object = nrow(x = findings),
          expected = 0L
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "skips sk- inside a longer name"),
      code = {
        fake_openai <- paste0("sk-", strrep(x = "a", times = 40))
        writeLines(
          text = c(
            # split, so the scanner in an older image does not flag it
            paste0(
              "dsem-smoke/task-1-rep-1-",
              "alternative-200-20261027-183325/"
            ),
            paste0("OPENAI_API_KEY=", fake_openai),
            paste0("\"", fake_openai, "\""),
            fake_openai
          ),
          con = file.path(root, "names.md")
        )
        findings <- suppressWarnings(
          expr = SecretScan(path = root, error = FALSE)
        )
        testthat::expect_equal(
          object = findings$line[findings$file == "names.md"],
          expected = 2:4
        )
        unlink(x = file.path(root, "names.md"))
      }
    )
    unlink(x = root, recursive = TRUE)
  },
  text = "test-rProject-secret-scan"
)
