.LintGif <- function(path) {
  # GIFs: size and source; a paper with an animation shows small multiples
  gifs <- .LintList(path = path, pattern = "\\.gif$")
  figures <- file.path(".setup", "latex", "figures")
  listed <- file.path(
    figures,
    list.files(
      path = file.path(path, figures),
      pattern = "\\.gif$",
      recursive = TRUE
    )
  )
  gifs <- unique(x = c(gifs, listed[file.exists(file.path(path, listed))]))
  sources <- .LintList(
    path = path,
    pattern = "\\.(R|Rmd|qmd|Rtex)$|\\.Rmd\\.orig$"
  )
  text <- unlist(x = lapply(X = sources, FUN = .LintRead, path = path))
  size <- lapply(
    X = gifs,
    FUN = function(file) {
      name <- sub(
        pattern = "\\.gif$",
        replacement = "",
        x = basename(path = file)
      )
      problems <- c(
        if (file.size(file.path(path, file)) > 10 * 1024^2) {
          "over 10 MB"
        },
        if (!any(grepl(pattern = name, x = text, fixed = TRUE))) {
          "no source: make it with Fig*() and GifWrite(), or a script"
        }
      )
      .LintRow(
        file = rep(x = file, times = length(x = problems)),
        line = rep(x = 1L, times = length(x = problems)),
        rule = "gif",
        message = problems
      )
    }
  )
  papers <- lapply(
    X = .LintTexSources(path = path, preamble = FALSE),
    FUN = function(file) {
      lines <- .LintTexStrip(lines = .LintRead(path = path, file = file))
      hit <- grep(pattern = "\\animategraphics", x = lines, fixed = TRUE)
      if (length(
        x = hit
      ) > 0L && !any(
        grepl(pattern = "\\includegraphics", x = lines, fixed = TRUE)
      )) {
        .LintRow(
          file = rep(x = file, times = length(x = hit)),
          line = hit,
          rule = "gif",
          message = "show small multiples next to the animation"
        )
      } else {
        NULL
      }
    }
  )
  .LintBind(rows = c(size, papers))
}
