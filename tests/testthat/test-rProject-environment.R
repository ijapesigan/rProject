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
    lines <- readLines(renviron)
    testthat::test_that(
      paste(text, "writes .Renviron with paths, project, and tokens"),
      {
        testthat::expect_true(
          any(grepl("^R_LIBS_USER=\".*/\\.library\"$", lines))
        )
        testthat::expect_true("PROJECT=\"testProject\"" %in% lines)
        testthat::expect_true("TEST_TOKEN=\"not-a-real-token\"" %in% lines)
        testthat::expect_true("R_COMPLETION=TRUE" %in% lines)
      }
    )
    testthat::test_that(
      paste(text, "makes .Renviron readable by the owner only"),
      {
        testthat::skip_on_os("windows")
        testthat::expect_equal(format(file.info(renviron)$mode), "600")
      }
    )
    testthat::test_that(
      paste(text, "sets the session variables"),
      {
        testthat::expect_equal(Sys.getenv("PROJECT"), "testProject")
        testthat::expect_equal(Sys.getenv("TEST_TOKEN"), "not-a-real-token")
      }
    )
    testthat::test_that(
      paste(text, "works without tokens"),
      {
        Environment(path = root, project = "testProject", tokens = NULL)
        testthat::expect_false(
          any(grepl("TEST_TOKEN", readLines(renviron)))
        )
      }
    )
    .TestRestore(state)
    unlink(dirname(root), recursive = TRUE)
  },
  text = "test-rProject-environment"
)
