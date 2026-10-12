## ---- test-rProject-environment-tokens
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    state <- .TestState(vars = c("TEST_A", "TEST_B"))
    testthat::test_that(
      paste(text, "sets each token and returns them"),
      {
        tokens <- c(TEST_A = "a", TEST_B = "b")
        testthat::expect_equal(EnvironmentTokens(tokens = tokens), tokens)
        testthat::expect_equal(Sys.getenv(c("TEST_A", "TEST_B")), tokens)
      }
    )
    .TestRestore(state)
  },
  text = "test-rProject-environment-tokens"
)
