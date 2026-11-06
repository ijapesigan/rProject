## ---- test-rProject-lint-house
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::test_that(
      desc = paste(text, "talks run the kept checks only"),
      code = {
        talk <- .LintChecks(type = "talk")
        testthat::expect_true(
          object = all(c(".LintTexBold", ".LintTexMath") %in% talk)
        )
        testthat::expect_false(
          object = any(c(".LintTexIndent", ".LintTexFloats") %in% talk)
        )
        testthat::expect_true(
          object = ".LintTexIndent" %in% .LintChecks(type = "man")
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "talks may use any biblatex-apa citation"),
      code = {
        root <- .TestLintProject(
          files = list(".setup/latex/a.tex" = "\\\\footcite{a}")
        )
        testthat::expect_equal(
          object = nrow(x = .LintTexCite(path = root, talk = TRUE)),
          expected = 0L
        )
        testthat::expect_equal(
          object = nrow(x = .LintTexCite(path = root)),
          expected = 1L
        )
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      desc = paste(text, "the level follows lint_error in project.R"),
      code = {
        root <- .TestProject()
        testthat::expect_equal(
          object = .LintLevel(path = root),
          expected = "warning"
        )
        write(
          x = "lint_error <- TRUE",
          file = file.path(root, ".setup", "scripts", "project.R"),
          append = TRUE
        )
        testthat::expect_equal(
          object = .LintLevel(path = root),
          expected = "error"
        )
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      desc = paste(text, "the report prints and returns its rows"),
      code = {
        rows <- .LintRow(file = "a", line = 1L, rule = "r", message = "m")
        testthat::expect_output(object = .LintReport(rows = rows), regexp = "a")
        testthat::expect_output(
          object = .LintReport(rows = rows[0L, ]),
          regexp = "nothing"
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "BigCamelCase becomes the file name"),
      code = {
        testthat::expect_equal(
          object = .LintKebab(x = c("LibCheck", "AIGlobal", "TinyTex")),
          expected = c("lib-check", "ai-global", "tiny-tex")
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "the template writes the test helpers once"),
      code = {
        root <- .TestLintProject(
          files = list("tests/testthat/test-testProject-a.R" = "x <- 1")
        )
        template <- system.file("template", package = "rProject")
        testthat::skip_if_not(
          condition = dir.exists(paths = file.path(template, "once"))
        )
        written <- .TemplateOnce(path = root, root = template, check = FALSE)
        testthat::expect_length(object = written, n = 2L)
        testthat::expect_length(
          object = .TemplateOnce(path = root, root = template, check = FALSE),
          n = 0L
        )
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-lint-house"
)
