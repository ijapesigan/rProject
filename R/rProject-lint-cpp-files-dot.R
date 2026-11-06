.LintCppFiles <- function(path) {
  level <- .LintLevel(path = path)
  pkg <- .LintPkg(path = path)
  files <- .LintCppList(path = path)
  good <- paste0("^(000-forward-declarations|", pkg, "-[a-z0-9-]+)\\.cpp$")
  bad <- files[!grepl(pattern = good, x = basename(path = files))]
  .LintRow(
    file = bad,
    line = rep(x = 1L, times = length(x = bad)),
    rule = "cpp-file-name",
    message = paste0(
      "name it ",
      pkg,
      "-<name>.cpp or ",
      pkg,
      "-<name>-dot.cpp"
    ),
    level = level
  )
}
