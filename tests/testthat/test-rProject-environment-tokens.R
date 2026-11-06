## ---- test-rProject-environment-tokens
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    state <- .TestState(vars = c("TEST_A", "TEST_B"))
    testthat::test_that(
      desc = paste(text, "sets each token and returns them"),
      code = {
        tokens <- c(TEST_A = "a", TEST_B = "b")
        testthat::expect_equal(
          object = EnvironmentTokens(tokens = tokens),
          expected = tokens
        )
        testthat::expect_equal(
          object = Sys.getenv(x = c("TEST_A", "TEST_B")),
          expected = tokens
        )
      }
    )
    .TestRestore(state = state)
  },
  text = "test-rProject-environment-tokens"
)
