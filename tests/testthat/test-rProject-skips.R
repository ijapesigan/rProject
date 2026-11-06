## ---- test-rProject-skips
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    .SkipState <- function(expr) {
      tryCatch(
        expr = {
          expr
          "ran"
        },
        skip = function(e) {
          "skipped"
        }
      )
    }
    testthat::test_that(
      paste(text, "SkipIfMissing skips on CI and for a missing program"),
      {
        testthat::expect_identical(
          object = .SkipState(
            expr = .SkipIfMissing(program = "no-such-program")
          ),
          expected = "skipped"
        )
      }
    )
    testthat::test_that(
      paste(text, "SkipSlow follows RPROJECT_SLOW_TESTS when not on CI"),
      {
        testthat::skip_on_ci()
        state <- .TestState(vars = "RPROJECT_SLOW_TESTS")
        Sys.setenv(RPROJECT_SLOW_TESTS = "")
        testthat::expect_identical(
          object = .SkipState(expr = .SkipSlow()),
          expected = "skipped"
        )
        Sys.setenv(RPROJECT_SLOW_TESTS = "true")
        testthat::expect_identical(
          object = .SkipState(expr = .SkipSlow()),
          expected = "ran"
        )
        .TestRestore(state = state)
      }
    )
    testthat::test_that(
      paste(text, "make agents has its install scripts"),
      {
        shell <- system.file("shell", package = "rProject")
        testthat::skip_if(condition = !nzchar(x = shell))
        testthat::expect_true(
          object = all(
            file.exists(
              file.path(
                shell,
                paste0(
                  "install-",
                  c("claude", "codex", "gemini", "copilot", "gh"),
                  ".sh"
                )
              )
            )
          )
        )
      }
    )
  },
  text = "test-rProject-skips"
)
