## ---- test-rProject-environment-project
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    state <- .TestState(vars = "PROJECT")
    testthat::test_that(
      desc = paste(text, "sets PROJECT and returns it"),
      code = {
        out <- EnvironmentProject(project = c("first", "second"))
        testthat::expect_equal(object = out, expected = c(PROJECT = "first"))
        testthat::expect_equal(
          object = Sys.getenv(x = "PROJECT"),
          expected = "first"
        )
      }
    )
    .TestRestore(state = state)
  },
  text = "test-rProject-environment-project"
)
