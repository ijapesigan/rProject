.LintMakeApptainer <- function(path) {
  # targets assume they already run inside the container (guide 007); a recipe
  # line that only prints a message is fine
  files <- .LintList(path = path, pattern = "(^|/)Makefile$")
  rows <- lapply(
    X = files,
    FUN = function(file) {
      lines <- readLines(con = file.path(path, file), warn = FALSE)
      hit <- which(
        x = grepl(pattern = "^\t.*\\bapptainer\\b", x = lines) &
          !grepl(pattern = "^\t@?-?echo\\b", x = lines)
      )
      .LintRow(
        file = rep_len(x = file, length.out = length(x = hit)),
        line = hit,
        rule = "make-apptainer",
        message = "a recipe never calls apptainer"
      )
    }
  )
  .LintBind(rows = rows)
}
