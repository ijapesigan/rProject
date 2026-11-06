## ---- test-rProject-readme
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::skip_if_not(
      condition = rmarkdown::pandoc_available(),
      message = "pandoc not found"
    )
    root <- .TestProject()
    dir.create(path = file.path(root, ".setup", "readme"), recursive = TRUE)
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
      desc = paste(
        text,
        "renders README.md and removes the intermediate files"
      ),
      code = {
        suppressMessages(expr = suppressWarnings(expr = ReadMe(path = root)))
        readme <- file.path(root, "README.md")
        testthat::expect_true(object = file.exists(readme))
        testthat::expect_true(
          object = any(
            grepl(pattern = "\\[1\\] 2", x = readLines(con = readme))
          )
        )
        testthat::expect_false(
          object = any(
            file.exists(file.path(root, c("README.Rmd", "README.html")))
          )
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "does nothing without .setup/readme/README.Rmd"),
      code = {
        other <- .TestProject(name = "noReadme")
        ReadMe(path = other)
        testthat::expect_false(
          object = file.exists(file.path(other, "README.md"))
        )
        unlink(x = dirname(path = other), recursive = TRUE)
      }
    )
    unlink(x = dirname(path = root), recursive = TRUE)
  },
  text = "test-rProject-readme"
)
