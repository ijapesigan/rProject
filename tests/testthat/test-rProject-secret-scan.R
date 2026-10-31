## ---- test-rProject-secret-scan
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    # fake tokens are built at run time
    # so that this file does not trigger SecretScan or push protection
    fake_github <- paste0("ghp_", strrep("a", 36))
    fake_codecov <- "00000000-0000-0000-0000-000000000000"
    root <- tempfile(pattern = "secretscan")
    dir.create(
      file.path(root, ".setup", "scripts"),
      recursive = TRUE
    )
    dir.create(
      file.path(root, ".library"),
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
      paste(text, "finds secrets"),
      {
        testthat::expect_error(
          SecretScan(path = root)
        )
        findings <- suppressWarnings(
          SecretScan(path = root, error = FALSE)
        )
        testthat::expect_equal(
          sort(findings$type),
          c("codecov", "github")
        )
        testthat::expect_true(
          all(findings$file == ".setup/scripts/secrets.R")
        )
      }
    )
    testthat::test_that(
      paste(text, "masks values"),
      {
        findings <- suppressWarnings(
          SecretScan(path = root, error = FALSE)
        )
        testthat::expect_false(
          any(grepl(fake_github, findings$match, fixed = TRUE))
        )
        msg <- tryCatch(
          SecretScan(path = root),
          error = function(e) conditionMessage(e)
        )
        testthat::expect_false(
          grepl(fake_github, msg, fixed = TRUE)
        )
      }
    )
    testthat::test_that(
      paste(text, "passes when clean"),
      {
        unlink(file.path(root, ".setup", "scripts", "secrets.R"))
        findings <- suppressMessages(
          SecretScan(path = root)
        )
        testthat::expect_equal(
          nrow(findings),
          0L
        )
      }
    )
    testthat::test_that(
      paste(text, "skips sk- inside a longer name"),
      {
        fake_openai <- paste0("sk-", strrep("a", 40))
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
          SecretScan(path = root, error = FALSE)
        )
        testthat::expect_equal(
          findings$line[findings$file == "names.md"],
          2:4
        )
        unlink(file.path(root, "names.md"))
      }
    )
    unlink(root, recursive = TRUE)
  },
  text = "test-rProject-secret-scan"
)
