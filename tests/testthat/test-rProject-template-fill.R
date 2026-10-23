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
  },
  text = "test-rProject-template-fill"
)
