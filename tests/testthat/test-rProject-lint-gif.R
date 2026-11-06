## ---- test-rProject-lint-gif
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::test_that(
      desc = paste(text, "flags a GIF without a source"),
      code = {
        root <- .TestLintProject(
          files = list(".setup/latex/figures/gif/a.gif" = "x")
        )
        rows <- .LintGif(path = root)
        testthat::expect_true(object = any(rows$rule == "gif"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      desc = paste(text, "passes a GIF named in a script"),
      code = {
        root <- .TestLintProject(
          files = list(
            ".setup/latex/figures/gif/a.gif" = "x",
            ".setup/latex/r-scripts/b.R" = "f <- \"a.gif\""
          )
        )
        rows <- .LintGif(path = root)
        testthat::expect_false(object = any(rows$rule == "gif"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-lint-gif"
)
