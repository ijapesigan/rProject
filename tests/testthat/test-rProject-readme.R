## ---- test-rProject-readme
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::skip_if_not(rmarkdown::pandoc_available(), "pandoc not found")
    root <- .TestProject()
    dir.create(file.path(root, ".setup", "readme"), recursive = TRUE)
    writeLines(
      text = c(
        "---",
        "output: github_document",
        "---",
        "",
        "# testProject",
        "",
        "```{r}",
        "1 + 1",
        "```"
      ),
      con = file.path(root, ".setup", "readme", "README.Rmd")
    )
    testthat::test_that(
      paste(text, "renders README.md and removes the intermediate files"),
      {
        suppressMessages(suppressWarnings(ReadMe(path = root)))
        readme <- file.path(root, "README.md")
        testthat::expect_true(file.exists(readme))
        testthat::expect_true(any(grepl("\\[1\\] 2", readLines(readme))))
        testthat::expect_false(
          any(file.exists(file.path(root, c("README.Rmd", "README.html"))))
        )
      }
    )
    testthat::test_that(
      paste(text, "does nothing without .setup/readme/README.Rmd"),
      {
        other <- .TestProject(name = "noReadme")
        ReadMe(path = other)
        testthat::expect_false(file.exists(file.path(other, "README.md")))
        unlink(dirname(other), recursive = TRUE)
      }
    )
    unlink(dirname(root), recursive = TRUE)
  },
  text = "test-rProject-readme"
)
