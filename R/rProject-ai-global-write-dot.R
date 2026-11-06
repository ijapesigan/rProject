.AIGlobalWrite <- function(file,
                           text) {
  exists <- file.exists(file)
  changed <- TRUE
  if (exists) {
    changed <- !identical(
      x = readLines(
        con = file,
        warn = FALSE
      ),
      y = text
    )
  }
  if (changed) {
    if (exists) {
      file.copy(
        from = file,
        to = paste0(file, ".bak"),
        overwrite = TRUE
      )
      Sys.chmod(
        paths = paste0(file, ".bak"),
        mode = "600"
      )
    }
    dir.create(
      path = dirname(path = file),
      showWarnings = FALSE,
      recursive = TRUE
    )
    writeLines(
      text = text,
      con = file
    )
    Sys.chmod(
      paths = file,
      mode = "600"
    )
    file
  }
}
