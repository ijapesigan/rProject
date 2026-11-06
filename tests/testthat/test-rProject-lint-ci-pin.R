## ---- test-rProject-lint-ci-pin
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    moving <- "\\buses:\\s*\\S+@(main|master|develop|dev|latest)\\b"
    testthat::test_that(
      desc = paste(text, "flags what the rule forbids"),
      code = {
        root <- .TestLintProject(
          files = list(".github/workflows/a.yml" = "  - uses: x/y@main")
        )
        rows <- .LintCiPin(path = root)
        testthat::expect_identical(object = rows$rule, expected = "ci-pin")
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      desc = paste(text, "passes what the rule allows"),
      code = {
        root <- .TestLintProject(
          files = list(".github/workflows/a.yml" = "  - uses: x/y@v2.0.0")
        )
        testthat::expect_identical(
          object = nrow(x = .LintCiPin(path = root)),
          expected = 0L
        )
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      desc = paste(text, "no template workflow uses a moving branch"),
      code = {
        root <- system.file("template", package = "rProject")
        testthat::skip_if(condition = !nzchar(x = root))
        files <- list.files(
          path = root,
          pattern = "\\.ya?ml$",
          recursive = TRUE,
          full.names = TRUE
        )
        hits <- vapply(
          X = files,
          FUN = function(file) {
            lines <- readLines(con = file, warn = FALSE)
            any(grepl(pattern = moving, x = lines))
          },
          FUN.VALUE = logical(length = 1)
        )
        testthat::expect_identical(
          object = basename(path = files[hits]),
          expected = character(length = 0)
        )
      }
    )
  },
  text = "test-rProject-lint-ci-pin"
)
