## ---- test-rProject-environment
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    state <- .TestState(vars = c(
      "PROJECT", "R_LIBS_USER", "R_PROFILE_USER", "R_HISTFILE", "TEST_TOKEN"
    ))
    root <- .TestProject(pattern = "project with space ")
    Environment(
      path = root,
      project = "testProject",
      tokens = c(TEST_TOKEN = "not-a-real-token")
    )
    renviron <- file.path(root, ".Renviron")
    lines <- readLines(con = renviron)
    testthat::test_that(
      desc = paste(text, "writes .Renviron with paths, project, and tokens"),
      code = {
        testthat::expect_true(
          object = any(
            grepl(pattern = "^R_LIBS_USER=\".*/\\.library\"$", x = lines)
          )
        )
        testthat::expect_true(object = "PROJECT=\"testProject\"" %in% lines)
        testthat::expect_true(
          object = "TEST_TOKEN=\"not-a-real-token\"" %in% lines
        )
        testthat::expect_true(object = "R_COMPLETION=TRUE" %in% lines)
      }
    )
    testthat::test_that(
      desc = paste(text, "makes .Renviron readable by the owner only"),
      code = {
        testthat::skip_on_os(os = "windows")
        testthat::expect_equal(
          object = format(x = file.info(renviron)$mode),
          expected = "600"
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "sets the session variables"),
      code = {
        testthat::expect_equal(
          object = Sys.getenv(x = "PROJECT"),
          expected = "testProject"
        )
        testthat::expect_equal(
          object = Sys.getenv(x = "TEST_TOKEN"),
          expected = "not-a-real-token"
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "works without tokens"),
      code = {
        Environment(path = root, project = "testProject", tokens = NULL)
        testthat::expect_false(
          object = any(
            grepl(pattern = "TEST_TOKEN", x = readLines(con = renviron))
          )
        )
      }
    )
    .TestRestore(state = state)
    unlink(x = dirname(path = root), recursive = TRUE)
  },
  text = "test-rProject-environment"
)
