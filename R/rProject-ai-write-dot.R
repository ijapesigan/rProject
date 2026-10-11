.AIWrite <- function(file,
                     text) {
  changed <- TRUE
  if (file.exists(file)) {
    changed <- !identical(
      readLines(
        con = file,
        warn = FALSE
      ),
      text
    )
  }
  if (changed) {
    dir.create(
      path = dirname(file),
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
