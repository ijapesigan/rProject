.ConformLock <- function(path) {
  # the lock is written by the first make auto
  lock <- file.path(".setup", "scripts", "rproject.lock")
  if (file.exists(file.path(path, lock))) {
    .ConformEmpty()
  } else {
    .ConformRow(
      rule = "lock",
      class = "info",
      file = lock,
      message = "no lock yet (the first make auto writes it)"
    )
  }
}
