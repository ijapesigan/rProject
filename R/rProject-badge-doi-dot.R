.BadgeDoi <- function(path) {
  # the first doi in inst/CITATION, the project's own citation; the template's
  # placeholder, or none, gives no badge
  file <- file.path(
    path,
    "inst",
    "CITATION"
  )
  badge <- character(length = 0)
  if (file.exists(file)) {
    lines <- readLines(
      con = file,
      warn = FALSE
    )
    pattern <- paste0(
      "^[[:space:]]*doi[[:space:]]*=[[:space:]]*",
      "\"(10\\.[^\"[:space:]]+)\".*$"
    )
    found <- grep(pattern = pattern, x = lines, value = TRUE)
    if (length(x = found) > 0) {
      doi <- sub(pattern = pattern, replacement = "\\1", x = found[1])
      if (!grepl(pattern = "^10\\.0+/0+$", x = doi)) {
        badge <- paste0(
          "[![DOI](https://zenodo.org/badge/DOI/",
          doi,
          ".svg)](https://doi.org/",
          doi,
          ")"
        )
      }
    }
  }
  badge
}
