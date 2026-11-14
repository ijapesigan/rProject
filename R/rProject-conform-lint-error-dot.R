.ConformLintError <- function(path) {
  # `lint_error <- FALSE` keeps the R and C++ checks at warnings: the
  # project turns them on when its cleanup is done
  project_r <- file.path(path, ".setup", "scripts", "project.R")
  off <- file.exists(project_r) && any(
    grepl(
      pattern = "^lint_error <- FALSE",
      x = readLines(con = project_r, warn = FALSE)
    )
  )
  if (off) {
    .ConformRow(
      rule = "lint-error",
      class = "decide",
      file = ".setup/scripts/project.R",
      message = "lint_error <- FALSE: turn errors on when make lint is clean"
    )
  } else {
    .ConformEmpty()
  }
}
