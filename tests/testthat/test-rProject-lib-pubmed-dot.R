## ---- test-rProject-lib-pubmed-dot
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::test_that(
      desc = paste(text, "arguments"),
      code = {
        testthat::expect_identical(
          object = names(x = formals(fun = .LibPubMed)),
          expected = "doi"
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "live call"),
      code = {
        testthat::skip_if_offline()
        testthat::skip_on_cran()
        out <- .LibPubMed(doi = "10.1037/emo0000562")
        testthat::skip_if(condition = is.null(x = out))
        testthat::expect_true(
          object = grepl(
            pattern = "^Mindfulness plays an important role",
            x = .LibPubMedAbstract(xml = out$xml)
          )
        )
      }
    )
  },
  text = "test-rProject-lib-pubmed-dot"
)
