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
        testthat::expect_equal(settings$type, "docker")
        testthat::expect_equal(
          settings$workflows,
          c("docker-build-push-multi", "docker-build-push-daily-multi")
        )
        testthat::expect_equal(settings$workflow_daily, "docs")
        testthat::expect_null(settings$workflow_title)
        testthat::expect_null(settings$other)
        testthat::expect_equal(.TemplateType(path = root), "docker")
      }
    )
    testthat::test_that(
      paste(text, "is empty without project.R"),
      {
        testthat::expect_length(.TemplateSettings(path = tempdir()), 0L)
      }
    )
    unlink(dirname(root), recursive = TRUE)
  },
  text = "test-rProject-template-settings"
)
