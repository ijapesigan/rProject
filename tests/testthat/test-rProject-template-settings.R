## ---- test-rProject-template-settings
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    root <- .TestProject()
    writeLines(
      text = c(
        "project <- \"docker-docs\"",
        "type <- \"docker\"",
        "workflows <- c(",
        "  \"docker-build-push-multi\",",
        "  \"docker-build-push-daily-multi\"",
        ")",
        "workflow_daily <- \"docs\"",
        "workflow_title <- paste(\"not\", \"read\")",
        "other <- \"ignored\""
      ),
      con = file.path(root, ".setup", "scripts", "project.R")
    )
    testthat::test_that(
      paste(text, "reads constant settings only"),
      {
        settings <- .TemplateSettings(path = root)
        testthat::expect_equal(object = settings$type, expected = "docker")
        testthat::expect_equal(
          object = settings$workflows,
          expected = c(
            "docker-build-push-multi",
            "docker-build-push-daily-multi"
          )
        )
        testthat::expect_equal(
          object = settings$workflow_daily,
          expected = "docs"
        )
        testthat::expect_null(object = settings$workflow_title)
        testthat::expect_null(object = settings$other)
        testthat::expect_equal(
          object = .TemplateType(path = root),
          expected = "docker"
        )
      }
    )
    testthat::test_that(
      paste(text, "is empty without project.R"),
      {
        testthat::expect_length(
          object = .TemplateSettings(path = tempdir()),
          n = 0L
        )
      }
    )
    unlink(x = dirname(path = root), recursive = TRUE)
  },
  text = "test-rProject-template-settings"
)
