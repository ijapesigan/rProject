## ---- test-rProject-lint-make-apptainer
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::test_that(
      desc = paste(text, "flags what the rule forbids"),
      code = {
        root <- .TestLintProject(
          files = list("Makefile" = c("all:", "\t@apptainer exec x.sif make y"))
        )
        rows <- .LintMakeApptainer(path = root)
        testthat::expect_identical(object = rows$line, expected = 2L)
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      desc = paste(text, "passes comments and messages"),
      code = {
        root <- .TestLintProject(
          files = list(
            "Makefile" = c(
              "# apptainer exec <sif> make all",
              "all:",
              "\t@echo \"run apptainer on the host\""
            )
          )
        )
        testthat::expect_identical(
          object = nrow(x = .LintMakeApptainer(path = root)),
          expected = 0L
        )
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-lint-make-apptainer"
)
