.LintRmdFigChunks <- function(path) {
  # a chunk that makes a figure needs a label: an unnamed chunk's file name
  # shifts when a chunk is added
  files <- .LintList(path = path, pattern = "\\.(Rmd|qmd)$|\\.Rmd\\.orig$")
  .LintBind(
    rows = lapply(
      X = files,
      FUN = function(file) {
        lines <- .LintRead(path = path, file = file)
        opens <- grep(pattern = "^```\\{r", x = lines)
        closes <- grep(pattern = "^```\\s*$", x = lines)
        bad <- integer(length = 0L)
        for (open in opens) {
          close <- closes[closes > open][1]
          if (!is.na(x = close)) {
            body <- lines[seq(from = open, to = close)]
            makes <- any(
              grepl(
                pattern = "\\b(plot|ggplot|Fig[A-Z]\\w*)\\(",
                x = body,
                perl = TRUE
              )
            )
            named <- grepl(
              pattern = "^```\\{r[ ,]+[A-Za-z0-9_.-]+\\s*[,}]",
              x = lines[open]
            ) && !grepl(pattern = "^```\\{r[ ,]+[a-z.]+\\s*=", x = lines[open])
            labelled <- named ||
              any(grepl(pattern = "^#\\|\\s*label\\s*[:=]", x = body)) ||
              grepl(pattern = "label\\s*=", x = lines[open])
            if (makes && !labelled) {
              bad <- c(bad, open)
            }
          }
        }
        .LintRow(
          file = rep(x = file, times = length(x = bad)),
          line = bad,
          rule = "fig-chunk",
          message = "label the chunk that makes this figure"
        )
      }
    )
  )
}
