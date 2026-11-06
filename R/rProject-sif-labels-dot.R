.SifLabels <- function(file = "/.singularity.d/labels.json") {
  lines <- character(length = 0)
  if (file.exists(file)) {
    lines <- readLines(con = file, warn = FALSE)
  }
  value <- function(key) {
    hit <- grep(pattern = key, x = lines, fixed = TRUE, value = TRUE)[1]
    ifelse(
      test = is.na(x = hit),
      yes = "unknown",
      no = sub(pattern = '^.*:\\s*"([^"]*)".*$', replacement = "\\1", x = hit)
    )
  }
  c(
    built = value(key = "org.label-schema.build-date"),
    base = substr(
      x = value(key = "org.opencontainers.image.base.digest"),
      start = 1,
      stop = 19
    )
  )
}
