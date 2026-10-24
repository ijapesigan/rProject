## ---- test-rProject-template-fill
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::test_that(
      paste(text, "fills only the given keys"),
      {
        out <- .TemplateFill(
          text = c(
            "name: {{title}}",
            "cron: \"{{cron}}\"",
            "pattern={{version}} ${{ secrets.PAT }}"
          ),
          values = list(title = "Daily", cron = "0 3 * * *")
        )
        testthat::expect_equal(
          out,
          c(
            "name: Daily",
            "cron: \"0 3 * * *\"",
            "pattern={{version}} ${{ secrets.PAT }}"
          )
        )
      }
    )
    testthat::test_that(
      paste(text, "splits multi-line values and drops empty placeholders"),
      {
        out <- .TemplateFill(
          text = c(
            "on:",
            "{{schedule}}",
            "  workflow_dispatch:",
            "{{next}}"
          ),
          values = list(
            schedule = "  schedule:\n    - cron: \"0 0 * * *\"",
            `next` = ""
          )
        )
        testthat::expect_equal(
          out,
          c(
            "on:",
            "  schedule:",
            "    - cron: \"0 0 * * *\"",
            "  workflow_dispatch:"
          )
        )
      }
    )
    testthat::test_that(
      paste(text, "workflow_next starts each image it names"),
      {
        keys <- .TemplateKeys(
          settings = list(
            workflow_next = c(
              "ijapesigan/docker-docs",
              "ijapesigan/docker-rocker"
            )
          )
        )
        out <- .TemplateFill(text = "{{next}}", values = keys["next"])
        testthat::expect_equal(
          sum(out == "      - name: Trigger the next image"),
          2L
        )
        testthat::expect_true(
          any(grepl(pattern = "repos/ijapesigan/docker-rocker/", x = out))
        )
        testthat::expect_identical(.TemplateKeys()[["next"]], "")
      }
    )
  },
  text = "test-rProject-template-fill"
)
