## ---- test-rProject-cff
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::skip_if_not_installed(pkg = "cffr")
    testthat::test_that(
      desc = paste(text, "writes CITATION.cff for a package"),
      code = {
        root <- normalizePath(path = .TestProject())
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
        # run from another folder: CFF() must not depend on the working
        # directory
        elsewhere <- tempfile(pattern = "elsewhere")
        dir.create(path = elsewhere)
        wd <- setwd(dir = elsewhere)
        on.exit(expr = setwd(dir = wd), add = TRUE)
        suppressMessages(expr = CFF(path = root))
        cff <- file.path(root, "CITATION.cff")
        testthat::expect_true(object = file.exists(cff))
        testthat::expect_true(
          object = any(grepl(pattern = "testProject", x = readLines(con = cff)))
        )
        testthat::expect_false(
          object = file.exists(file.path(elsewhere, "CITATION.cff"))
        )
        setwd(dir = wd)
        unlink(x = c(dirname(path = root), elsewhere), recursive = TRUE)
      }
    )
    testthat::test_that(
      desc = paste(text, "skips folders that are not packages"),
      code = {
        root <- .TestProject(description = FALSE)
        testthat::expect_message(
          object = CFF(path = root),
          regexp = "is not an R package"
        )
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-cff"
)
