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
  },
  text = "test-rProject-template-fill"
)
