## ---- test-rProject-cff
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::skip_if_not_installed("cffr")
    testthat::test_that(
      paste(text, "writes CITATION.cff for a package"),
      {
        root <- .TestProject()
        writeLines(
          text = c(
            "Package: testProject",
            "Title: Test Project",
            "Version: 0.0.1",
            "Authors@R: person(\"Jane\", \"Doe\",",
            "  email = \"jane@example.com\",",
            "  role = c(\"aut\", \"cre\"))",
            "Description: A test project.",
            "License: MIT + file LICENSE",
            "URL: https://github.com/example/testProject",
            "Encoding: UTF-8"
          ),
          con = file.path(root, "DESCRIPTION")
        )
        # make cff runs from the project folder; cffr needs that
        wd <- setwd(root)
        on.exit(setwd(wd), add = TRUE)
        suppressMessages(CFF(path = root))
        cff <- file.path(root, "CITATION.cff")
        testthat::expect_true(file.exists(cff))
        testthat::expect_true(any(grepl("testProject", readLines(cff))))
        unlink(dirname(root), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "skips folders that are not packages"),
      {
        root <- .TestProject(description = FALSE)
        testthat::expect_message(CFF(path = root), "is not an R package")
        unlink(dirname(root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-cff"
)
