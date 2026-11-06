.DataManifestRead <- function(file) {
  empty <- data.frame(
    file = character(length = 0),
    tier = character(length = 0),
    size = character(length = 0),
    md5 = character(length = 0),
    status = character(length = 0),
    source = character(length = 0),
    location = character(length = 0),
    stringsAsFactors = FALSE
  )
  rows <- character(length = 0)
  if (file.exists(file)) {
    lines <- readLines(con = file, warn = FALSE)
    rows <- lines[grepl(pattern = "^\\| `", x = lines)]
  }
  if (length(x = rows) == 0L) {
    empty
  } else {
    cells <- lapply(
      X = strsplit(x = rows, split = "|", fixed = TRUE),
      FUN = function(x) {
        trimws(x = gsub(pattern = "`", replacement = "", x = x[-1]))
      }
    )
    data.frame(
      file = vapply(X = cells, FUN = `[`, FUN.VALUE = "", 1),
      tier = vapply(X = cells, FUN = `[`, FUN.VALUE = "", 2),
      size = vapply(X = cells, FUN = `[`, FUN.VALUE = "", 3),
      md5 = vapply(X = cells, FUN = `[`, FUN.VALUE = "", 4),
      status = vapply(X = cells, FUN = `[`, FUN.VALUE = "", 5),
      source = vapply(X = cells, FUN = `[`, FUN.VALUE = "", 6),
      location = vapply(X = cells, FUN = `[`, FUN.VALUE = "", 7),
      stringsAsFactors = FALSE
    )
  }
}
