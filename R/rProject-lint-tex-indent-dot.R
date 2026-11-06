.LintTexIndent <- function(path) {
  .LintBind(
    rows = lapply(
      X = .LintTexSources(path = path, preamble = FALSE),
      FUN = function(file) {
        lines <- .LintTexStrip(lines = .LintRead(path = path, file = file))
        depth <- 0L
        bad <- integer(length = 0L)
        for (i in seq_along(along.with = lines)) {
          line <- gsub(
            pattern = "\\\\(begin|end)\\{document\\}",
            replacement = "",
            x = lines[i]
          )
          if (depth > 0L && grepl(pattern = "^ +\\S", x = line)) {
            bad <- c(bad, i)
          }
          depth <- depth +
            lengths(
              x = regmatches(
                x = line,
                m = gregexpr(pattern = "\\\\begin\\{", text = line)
              )
            ) -
            lengths(
              x = regmatches(
                x = line,
                m = gregexpr(pattern = "\\\\end\\{", text = line)
              )
            )
        }
        .LintRow(
          file = rep(x = file, times = length(x = bad)),
          line = bad,
          rule = "tex-indent",
          message = "indent environments with one tab"
        )
      }
    )
  )
}
