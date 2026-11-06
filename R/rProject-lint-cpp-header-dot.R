.LintCppHeader <- function(path) {
  level <- .LintLevel(path = path)
  .LintBind(
    rows = lapply(
      X = .LintCppList(path = path),
      FUN = function(file) {
        lines <- .LintRead(path = path, file = file)
        hit <- grep(pattern = "^// edit \\.setup/cpp/", x = lines)
        wanted <- paste0("// edit .setup/cpp/", basename(path = file))
        if (length(x = hit) == 0L) {
          .LintRow(
            file = file,
            line = 1L,
            rule = "cpp-header",
            message = paste0("add `", wanted, "`"),
            level = level
          )
        } else if (!(wanted %in% trimws(x = lines[hit]))) {
          .LintRow(
            file = file,
            line = hit[1],
            rule = "cpp-header",
            message = paste0("the header should say `", wanted, "`"),
            level = level
          )
        } else {
          NULL
        }
      }
    )
  )
}
