.AISettings <- function(path) {
  project_r <- file.path(path, ".setup", "scripts", "project.R")
  ai <- list()
  if (file.exists(project_r)) {
    env <- new.env(parent = baseenv())
    try(
      sys.source(file = project_r, envir = env),
      silent = TRUE
    )
    ai <- get0(x = "ai", envir = env, inherits = FALSE, ifnotfound = list())
  }
  ai
}
