## ---- test-rProject-pkgdown-template
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    pkgdown <- system.file(
      "pkgdown",
      "_pkgdown.yml",
      package = "rProject"
    )
    testthat::test_that(
      paste(text, "pkgdown template is installed"),
      {
        testthat::expect_true(
          object = nzchar(x = pkgdown) && file.exists(pkgdown)
        )
      }
    )
    lines <- readLines(con = pkgdown)
    testthat::test_that(
      paste(text, "pkgdown template settings"),
      {
        testthat::expect_true(
          object = "template:" %in% lines
        )
        testthat::expect_true(
          object = any(grepl(pattern = "^  bootstrap: 5$", x = lines))
        )
        testthat::expect_true(
          object = any(grepl(pattern = "^  math-rendering: katex$", x = lines))
        )
      }
    )
    scss <- vapply(
      X = c("lib", "man", "talk"),
      FUN = function(set) {
        system.file(
          "template",
          set,
          "dot-setup",
          "quarto",
          "scss",
          "custom.scss",
          package = "rProject"
        )
      },
      FUN.VALUE = character(length = 1)
    )
    testthat::test_that(
      paste(text, "Quarto custom.scss copies are identical"),
      {
        testthat::expect_true(
          object = all(nzchar(x = scss))
        )
        contents <- lapply(
          X = scss,
          FUN = readLines
        )
        testthat::expect_identical(
          object = contents[[1]],
          expected = contents[[2]]
        )
        testthat::expect_identical(
          object = contents[[1]],
          expected = contents[[3]]
        )
      }
    )
  },
  text = "test-rProject-pkgdown-template"
)
