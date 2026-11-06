.LintKebab <- function(x) {
  # BigCamelCase to the name in a file: LibCheck to lib-check, AIGlobal to
  # ai-global
  x <- gsub(pattern = "([a-z0-9])([A-Z])", replacement = "\\1-\\2", x = x)
  x <- gsub(pattern = "([A-Z])([A-Z][a-z])", replacement = "\\1-\\2", x = x)
  tolower(x = x)
}
