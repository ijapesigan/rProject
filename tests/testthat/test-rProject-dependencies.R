## ---- test-rProject-dependencies
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::test_that(
      paste(text, "copies .setup/r-dependencies into R/"),
      {
        root <- .TestProject()
        deps <- file.path(root, ".setup", "r-dependencies")
        dir.create(deps, recursive = TRUE)
        writeLines("Dep <- function() 1", file.path(deps, "testProject-dep.R"))
        Dependencies(path = root)
        testthat::expect_true(
          file.exists(file.path(root, "R", "testProject-dep.R"))
        )
        unlink(dirname(root), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "replaces stale copies in R/"),
      {
        root <- .TestProject()
        deps <- file.path(root, ".setup", "r-dependencies")
        dir.create(deps, recursive = TRUE)
        dir.create(file.path(root, "R"), showWarnings = FALSE)
        writeLines(
          "Dep <- function() 1",
          file.path(root, "R", "testProject-dep.R")
        )
        writeLines("Dep <- function() 2", file.path(deps, "testProject-dep.R"))
        Dependencies(path = root)
        testthat::expect_identical(
          readLines(file.path(root, "R", "testProject-dep.R")),
          "Dep <- function() 2"
        )
        unlink(dirname(root), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "skips folders that are not packages"),
      {
        root <- .TestProject(description = FALSE)
        testthat::expect_message(
          Dependencies(path = root),
          "is not an R package"
        )
        unlink(dirname(root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-dependencies"
)
