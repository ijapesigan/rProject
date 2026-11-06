## ---- test-rProject-profile
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    state <- .TestState()
    testthat::test_that(
      desc = paste(text, "writes .Rprofile for a package"),
      code = {
        root <- .TestProject(pattern = "project with space ")
        Profile(path = root, project = "testProject")
        profile <- readLines(con = file.path(root, ".Rprofile"))
        testthat::expect_true(
          object = any(grepl(
            pattern = "Sys.setenv(PROJECT = \"testProject\")", x = profile,
            fixed = TRUE
          ))
        )
        testthat::expect_true(
          object = any(grepl(pattern = "^\\.libPaths\\(", x = profile))
        )
        testthat::expect_true(
          object = any(
            grepl(pattern = "options(repos", x = profile, fixed = TRUE)
          )
        )
        # the file is valid R
        testthat::expect_silent(
          object = parse(file = file.path(root, ".Rprofile"))
        )
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    testthat::test_that(
      desc = paste(text, "skips folders that are not packages"),
      code = {
        root <- .TestProject(description = FALSE)
        testthat::expect_message(
          object = Profile(path = root, project = "testProject"),
          regexp = "is not an R package"
        )
        testthat::expect_false(
          object = file.exists(file.path(root, ".Rprofile"))
        )
        unlink(x = dirname(path = root), recursive = TRUE)
      }
    )
    .TestRestore(state = state)
  },
  text = "test-rProject-profile"
)
