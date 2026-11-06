.LintMdFences <- function(path) {
  .LintBind(
    rows = lapply(
      X = .LintMdList(path = path),
      FUN = function(file) {
        lines <- .LintRead(path = path, file = file)
        fences <- grep(pattern = "^\\s*```", x = lines)
        # every other fence opens a block
        opening <- fences[c(TRUE, FALSE)]
        opening <- opening[!is.na(x = opening)]
        bad <- opening[grepl(pattern = "^\\s*```\\s*$", x = lines[opening])]
        .LintRow(
          file = rep(x = file, times = length(x = bad)),
          line = bad,
          rule = "md-fence",
          message = "name the language of the code block"
        )
      }
    )
  )
}
