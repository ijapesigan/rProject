.AIWrite <- function(file,
                     text) {
  changed <- TRUE
  if (file.exists(file)) {
    changed <- !identical(
      x = readLines(
        con = file,
        warn = FALSE
      ),
      y = text
    )
  }
  if (changed) {
    dir.create(
      path = dirname(path = file),
      showWarnings = FALSE,
      recursive = TRUE
    )
    # no backup: a .bak copy would not be gitignored
    writeLines(
      text = text,
      con = file
    )
    file
  }
}
