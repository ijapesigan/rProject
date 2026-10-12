## ---- test-rProject-environment-project
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    state <- .TestState(vars = "PROJECT")
    testthat::test_that(
      paste(text, "sets PROJECT and returns it"),
      {
        out <- EnvironmentProject(project = c("first", "second"))
        testthat::expect_equal(out, c(PROJECT = "first"))
        testthat::expect_equal(Sys.getenv("PROJECT"), "first")
      }
    )
    .TestRestore(state)
  },
  text = "test-rProject-environment-project"
)
