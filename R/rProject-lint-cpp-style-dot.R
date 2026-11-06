.LintCppStyle <- function() {
  # the clang-format style of make style and make lint: Google, with braces
  shQuote(string = "-style={BasedOnStyle: Google, InsertBraces: true}")
}
