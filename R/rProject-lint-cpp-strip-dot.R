.LintCppStrip <- function(lines) {
  # blank comments and strings; line numbers hold
  lines <- gsub(
    pattern = "\"(\\\\.|[^\"\\\\])*\"",
    replacement = "\"\"",
    x = lines,
    perl = TRUE
  )
  sub(pattern = "//.*$", replacement = "", x = lines)
}
