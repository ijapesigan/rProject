.LintLevel <- function(path) {
  # the level of the R and C++ checks: a project turns errors on in its own
  # cleanup push, with `lint_error <- TRUE` in .setup/scripts/project.R
  project_r <- file.path(path, ".setup", "scripts", "project.R")
  on <- FALSE
  if (file.exists(project_r)) {
    on <- any(
      grepl(
        pattern = "^lint_error <- TRUE",
        x = readLines(con = project_r, warn = FALSE)
      )
    )
  }
  ifelse(test = on, yes = "error", no = "warning")
}
