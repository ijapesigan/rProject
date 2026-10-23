.LockRead <- function(path) {
  # the lock as a list (empty without one)
  lock <- file.path(path, ".setup", "scripts", "rproject.lock")
  out <- list()
  if (file.exists(lock)) {
    env <- new.env()
    sys.source(file = lock, envir = env)
    out <- as.list(env)
  }
  out
}
