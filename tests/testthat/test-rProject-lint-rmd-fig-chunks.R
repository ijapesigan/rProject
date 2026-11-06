## ---- test-rProject-lint-rmd-fig-chunks
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::test_that(
      paste(text, "flags what the rule forbids"),
      {
        root <- .TestLintProject(
          files = list("a.Rmd" = c("```{r}", "plot(1)", "```"))
        )
        rows <- .LintRmdFigChunks(path = root)
        testthat::expect_true(object = any(rows$rule == "fig-chunk"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "passes what the rule allows"),
      {
        root <- .TestLintProject(
          files = list("a.Rmd" = c("```{r fig-one}", "plot(1)", "```"))
        )
        rows <- .LintRmdFigChunks(path = root)
        testthat::expect_false(object = any(rows$rule == "fig-chunk"))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-lint-rmd-fig-chunks"
)
