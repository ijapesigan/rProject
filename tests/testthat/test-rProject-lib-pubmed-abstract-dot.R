## ---- test-rProject-lib-pubmed-abstract-dot
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    xml <- function(...) {
      paste0(
        "<PubmedArticle><Abstract>", paste0(..., collapse = ""),
        "</Abstract></PubmedArticle>"
      )
    }
    testthat::test_that(
      desc = paste(text, "unlabelled"),
      code = {
        testthat::expect_identical(
          object = .LibPubMedAbstract(
            xml = xml("<AbstractText>Mindfulness plays a role.</AbstractText>")
          ),
          expected = "Mindfulness plays a role."
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "labelled in sentence case, UNLABELLED dropped"),
      code = {
        out <- .LibPubMedAbstract(
          xml = xml(
            "<AbstractText Label=\"OBJECTIVES\" NlmCategory=\"OBJECTIVE\">",
            "Aim.</AbstractText>",
            "<AbstractText Label=\"UNLABELLED\">More.</AbstractText>"
          )
        )
        testthat::expect_identical(
          object = out,
          expected = "Objectives: Aim. More."
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "entities and tags"),
      code = {
        out <- .LibPubMedAbstract(
          xml = xml(
            "<AbstractText>Using <i>R</i> &amp; Stan, x&#233;.</AbstractText>"
          )
        )
        testthat::expect_identical(
          object = out,
          expected = "Using R \\& Stan, x{\\'e}."
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "PsycInfo note"),
      code = {
        out <- .LibPubMedAbstract(
          xml = xml(
            "<AbstractText>Text. (PsycInfo Database Record (c) 2020 APA, ",
            "all rights reserved)</AbstractText>"
          )
        )
        testthat::expect_identical(object = out, expected = "Text.")
      }
    )
    testthat::test_that(
      desc = paste(text, "quotes and statistics"),
      code = {
        out <- .LibPubMedAbstract(
          xml = xml(
            "<AbstractText>It was \"big\" (p &lt; .001, n = 42).",
            "</AbstractText>"
          )
        )
        testthat::expect_identical(
          object = out,
          expected = "It was ``big'' ($p < .001$, $n = 42$)."
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "no abstract"),
      code = {
        testthat::expect_identical(
          object = .LibPubMedAbstract(xml = "<PubmedArticle/>"),
          expected = NA_character_
        )
      }
    )
  },
  text = "test-rProject-lib-pubmed-abstract-dot"
)
