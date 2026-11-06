.LintMdHeadings <- function(path) {
  .LintBind(
    rows = lapply(
      X = .LintMdList(path = path),
      FUN = function(file) {
        lines <- .LintMdStrip(lines = .LintRead(path = path, file = file))
        previous <- c("", lines[-length(x = lines)])
        setext <- which(
          x = grepl(pattern = "^(={2,}|-{3,})\\s*$", x = lines) &
            nzchar(x = trimws(x = previous)) &
            !grepl(pattern = "^\\s*[|>-]", x = previous)
        )
        heads <- grep(pattern = "^#{1,6}\\s", x = lines)
        level <- nchar(
          x = sub(pattern = "^(#+).*$", replacement = "\\1", x = lines[heads])
        )
        titles <- heads[level == 1L]
        extra <- integer(length = 0L)
        if (basename(path = file) != "NEWS.md") {
          extra <- titles[-1L]
        }
        skipped <- heads[-1L][diff(x = level) > 1L]
        .LintBind(
          rows = list(
            .LintRow(
              file = rep(x = file, times = length(x = setext)),
              line = setext,
              rule = "md-heading",
              message = "use # headings"
            ),
            .LintRow(
              file = rep(x = file, times = length(x = extra)),
              line = extra,
              rule = "md-heading",
              message = "one # title per file"
            ),
            .LintRow(
              file = rep(x = file, times = length(x = skipped)),
              line = skipped,
              rule = "md-heading",
              message = "a heading level is skipped"
            )
          )
        )
      }
    )
  )
}
