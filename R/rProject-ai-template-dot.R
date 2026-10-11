.AITemplate <- function(file) {
  readLines(
    con = system.file(
      "ai",
      file,
      package = "rProject",
      mustWork = TRUE
    ),
    warn = FALSE
  )
}
