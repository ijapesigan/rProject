## ---- test-rProject-conform-checks
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    lint_output <- c(
      "Linting...",
      "R/foo.R:3:1: style: [indentation_linter] Indentation should be 2.",
      "R/foo.R:9:5: warning: [object_usage_linter] no visible binding",
      "House checks:",
      " rule     level   Freq",
      " md-fence warning 1",
      "",
      " file       line rule     message                 level  ",
      " README.md  12   md-fence The fence has no language warning",
      " Makefile   NA    sh-strict No set -e              warning"
    )
    test_output <- c(
      "-- Failure (test-pkg-foo.R:12:3): foo works --",
      "Failure (test-pkg-foo.R:12:3): foo works",
      "Error (test-pkg-bar.R:5:1): bar works",
      "[ FAIL 2 | WARN 0 | SKIP 1 | PASS 10 ]"
    )
    testthat::test_that(
      desc = paste(text, "lint messages and house rows become decide rows"),
      code = {
        rows <- .ConformLintRows(output = lint_output, status = 1L)
        testthat::expect_true(object = all(rows$rule == "lint"))
        testthat::expect_true(object = all(rows$class == "decide"))
        testthat::expect_setequal(
          object = rows$file,
          expected = c("R/foo.R:3", "R/foo.R:9", "README.md:12", "Makefile")
        )
        testthat::expect_true(
          object = any(grepl(pattern = "^style: ", x = rows$message))
        )
        testthat::expect_true(
          object = any(
            grepl(pattern = "[md-fence]", x = rows$message, fixed = TRUE)
          )
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "a house table wrapped by R is paired by order"),
      code = {
        wrapped <- c(
          "House checks:",
          " rule      level   Freq",
          " file-name warning 1   ",
          "",
          " file                 line rule     ",
          " R/wald-ci-wald-dot.R 1    file-name",
          " Makefile             NA   sh-strict",
          " message                         level  ",
          " name it R/deltaMethod-<name>.R  warning",
          " set -Eeuo pipefail first        warning",
          "i No lints found."
        )
        rows <- .ConformLintRows(output = wrapped, status = 0L)
        testthat::expect_equal(
          object = rows$file,
          expected = c("R/wald-ci-wald-dot.R:1", "Makefile")
        )
        testthat::expect_equal(
          object = rows$message,
          expected = c(
            "warning: [file-name] name it R/deltaMethod-<name>.R",
            "warning: [sh-strict] set -Eeuo pipefail first"
          )
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "a failing make lint with no row is one row"),
      code = {
        rows <- .ConformLintRows(output = "boom", status = 2L)
        testthat::expect_equal(object = nrow(x = rows), expected = 1L)
        testthat::expect_match(object = rows$message, regexp = "exit 2")
        clean <- .ConformLintRows(output = "House checks: nothing", status = 0L)
        testthat::expect_equal(object = nrow(x = clean), expected = 0L)
      }
    )
    testthat::test_that(
      desc = paste(text, "test failures and counts are rows"),
      code = {
        rows <- .ConformTestRows(output = test_output, status = 1L)
        testthat::expect_equal(object = nrow(x = rows), expected = 3L)
        testthat::expect_true(object = all(rows$class == "decide"))
        testthat::expect_match(object = rows$message[[1]], regexp = "FAIL 2")
        testthat::expect_true(
          object = "tests/testthat/test-pkg-bar.R:5" %in% rows$file
        )
        ok <- .ConformTestRows(
          output = "[ FAIL 0 | WARN 0 | SKIP 0 | PASS 4 ]",
          status = 0L
        )
        testthat::expect_equal(object = ok$class, expected = "info")
      }
    )
    testthat::test_that(
      desc = paste(text, "Conform() runs the checks only when asked"),
      code = {
        root <- .TestConform()
        calls <- character(length = 0)
        testthat::local_mocked_bindings(
          .ConformCommand = function(command, args, dir, env) {
            calls <<- c(calls, basename(path = command))
            list(
              status = 1L,
              output = c(
                "R/a.R:1:1: style: [x_linter] bad",
                "Failure (test-a.R:2:3): a",
                "[ FAIL 1 | WARN 0 | SKIP 0 | PASS 0 ]"
              )
            )
          }
        )
        plain <- suppressMessages(expr = Conform(path = root))
        testthat::expect_equal(object = length(x = calls), expected = 0L)
        testthat::expect_false(object = "lint" %in% plain$rule)
        logs <- tempfile()
        dir.create(path = logs)
        rows <- suppressMessages(
          expr = Conform(
            path = root,
            lint = TRUE,
            tests = TRUE,
            log_dir = logs
          )
        )
        testthat::expect_equal(object = calls, expected = c("make", "Rscript"))
        testthat::expect_true(object = "lint" %in% rows$rule)
        testthat::expect_true(object = "tests" %in% rows$rule)
        testthat::expect_true(
          object = all(file.exists(attr(x = rows, which = "logs")))
        )
        testthat::expect_message(
          object = Conform(path = root, lint = TRUE, log_dir = logs),
          regexp = "conform-lint.log"
        )
      }
    )
  },
  text = "test-rProject-conform-checks"
)
