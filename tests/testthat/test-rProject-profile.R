## ---- test-rProject-profile
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    state <- .TestState()
    testthat::test_that(
      paste(text, "writes .Rprofile for a package"),
      {
        root <- .TestProject()
        Profile(path = root, project = "testProject")
        profile <- readLines(file.path(root, ".Rprofile"))
        testthat::expect_true(
          any(grepl("Sys.setenv(PROJECT = \"testProject\")", profile,
            fixed = TRUE
          ))
        )
        testthat::expect_true(any(grepl("^\\.libPaths\\(", profile)))
        testthat::expect_true(
          any(grepl("options(repos", profile, fixed = TRUE))
        )
        # the file is valid R
        testthat::expect_silent(parse(file.path(root, ".Rprofile")))
        unlink(dirname(root), recursive = TRUE)
      }
    )
    testthat::test_that(
      paste(text, "skips folders that are not packages"),
      {
        root <- .TestProject(description = FALSE)
        testthat::expect_message(
          Profile(path = root, project = "testProject"),
          "is not an R package"
        )
        testthat::expect_false(file.exists(file.path(root, ".Rprofile")))
        unlink(dirname(root), recursive = TRUE)
      }
    )
    .TestRestore(state)
  },
  text = "test-rProject-profile"
)
