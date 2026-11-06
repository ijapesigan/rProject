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
        dir.create(path = deps, recursive = TRUE)
        writeLines(
          text = "Dep <- function() 1",
          con = file.path(deps, "testProject-dep.R")
        )
        Dependencies(path = root)
        testthat::expect_true(
          object = file.exists(file.path(root, "R", "testProject-dep.R"))
        )
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "replaces stale copies in R/"),
      {
        root <- .TestProject()
        deps <- file.path(root, ".setup", "r-dependencies")
        dir.create(path = deps, recursive = TRUE)
        dir.create(path = file.path(root, "R"), showWarnings = FALSE)
        writeLines(
          text = "Dep <- function() 1",
          con = file.path(root, "R", "testProject-dep.R")
        )
        writeLines(
          text = "Dep <- function() 2",
          con = file.path(deps, "testProject-dep.R")
        )
        Dependencies(path = root)
        testthat::expect_identical(
          object = readLines(con = file.path(root, "R", "testProject-dep.R")),
          expected = "Dep <- function() 2"
        )
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "skips folders that are not packages"),
      {
        root <- .TestProject(description = FALSE)
        testthat::expect_message(
          object = Dependencies(path = root),
          regexp = "is not an R package"
        )
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
  },
  text = "test-rProject-dependencies"
)
