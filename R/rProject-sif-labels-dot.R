.SifLabels <- function(file = "/.singularity.d/labels.json") {
  lines <- character(0)
  if (file.exists(file)) {
    lines <- readLines(con = file, warn = FALSE)
  }
  value <- function(key) {
    hit <- grep(pattern = key, x = lines, fixed = TRUE, value = TRUE)[1]
    ifelse(
      is.na(hit),
      "unknown",
      sub(pattern = '^.*:\\s*"([^"]*)".*$', replacement = "\\1", x = hit)
    )
  }
  c(
    built = value("org.label-schema.build-date"),
    base = substr(value("org.opencontainers.image.base.digest"), 1, 19)
  )
}
