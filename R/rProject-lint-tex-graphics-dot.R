.LintTexGraphics <- function(path) {
  images <- basename(
    path = .LintList(path = path, pattern = "\\.(pdf|png|jpg|jpeg)$")
  )
  images <- c(
    images,
    basename(
      path = list.files(
        path = file.path(path, ".setup", "latex", "figures"),
        recursive = TRUE
      )
    )
  )
  .LintBind(
    rows = lapply(
      X = .LintTexSources(path = path, preamble = FALSE),
      FUN = function(file) {
        lines <- .LintTexStrip(lines = .LintRead(path = path, file = file))
        scale <- grep(pattern = "\\\\includegraphics\\[[^]]*scale", x = lines)
        calls <- regmatches(
          x = lines,
          m = regexec(
            pattern = "\\\\includegraphics(?:\\[[^]]*\\])?\\{([^}]*)\\}",
            text = lines
          )
        )
        missing_file <- which(
          x = vapply(
            X = calls,
            FUN = function(call) {
              if (length(
                x = call
              ) < 2L || grepl(pattern = "[#\\\\]", x = call[2])) {
                FALSE
              } else {
                name <- basename(path = call[2])
                !(
                  name %in% images || any(
                    startsWith(x = images, prefix = paste0(name, "."))
                  )
                )
              }
            },
            FUN.VALUE = logical(length = 1)
          )
        )
        .LintBind(
          rows = list(
            .LintRow(
              file = rep(x = file, times = length(x = scale)),
              line = scale,
              rule = "tex-graphics",
              message = "use width = \\linewidth or \\textwidth, not scale"
            ),
            .LintRow(
              file = rep(x = file, times = length(x = missing_file)),
              line = missing_file,
              rule = "tex-graphics",
              message = "the file does not exist"
            )
          )
        )
      }
    )
  )
}
