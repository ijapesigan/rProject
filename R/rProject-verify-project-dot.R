.VerifyProject <- function(path) {
  project_r <- file.path(path, ".setup", "scripts", "project.R")
  project <- character(0)
  if (file.exists(project_r)) {
    lines <- readLines(
      con = project_r,
      warn = FALSE
    )
    hit <- regmatches(
      x = lines,
      m = regexpr(pattern = "^project <- \"[^\"]+\"", text = lines)
    )
    project <- sub(
      pattern = "^project <- \"([^\"]+)\"",
      replacement = "\\1",
      x = hit
    )
  }
  # the project folder name when project.R does not say
  c(project, basename(normalizePath(path)))[1]
}
