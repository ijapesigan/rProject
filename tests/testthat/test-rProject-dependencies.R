## ---- test-rProject-dependencies
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::test_that(
      desc = paste(text, "copies .setup/r-dependencies into R/"),
      code = {
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
      desc = paste(text, "replaces stale copies in R/"),
      code = {
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
      desc = paste(
        text,
        "removes a helper dropped from its set, not other files"
      ),
      code = {
        root <- .TestProject()
        deps <- file.path(root, ".setup", "r-dependencies", "lib")
        dir.create(path = deps, recursive = TRUE)
        dir.create(path = file.path(root, "R"), showWarnings = FALSE)
        writeLines(text = "x <- 1", con = file.path(deps, "lib-new.R"))
        writeLines(text = "x <- 1", con = file.path(root, "R", "lib-old.R"))
        writeLines(text = "x <- 1", con = file.path(root, "R", "own-file.R"))
        Dependencies(path = root)
        testthat::expect_false(
          object = file.exists(file.path(root, "R", "lib-old.R"))
        )
        testthat::expect_true(
          object = file.exists(file.path(root, "R", "lib-new.R"))
        )
        testthat::expect_true(
          object = file.exists(file.path(root, "R", "own-file.R"))
        )
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      desc = paste(
        text,
        "keeps the package's own files when a set has its name"
      ),
      code = {
        root <- .TestProject()
        package <- read.dcf(
          file = file.path(root, "DESCRIPTION"),
          fields = "Package"
        )[[1]]
        deps <- file.path(root, ".setup", "r-dependencies", package)
        dir.create(path = deps, recursive = TRUE)
        dir.create(path = file.path(root, "R"), showWarnings = FALSE)
        writeLines(
          text = "x <- 1",
          con = file.path(deps, paste0(package, "-helper.R"))
        )
        own <- file.path(root, "R", paste0(package, "-own.R"))
        writeLines(text = "x <- 1", con = own)
        Dependencies(path = root)
        testthat::expect_true(object = file.exists(own))
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      desc = paste(text, "skips folders that are not packages"),
      code = {
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
