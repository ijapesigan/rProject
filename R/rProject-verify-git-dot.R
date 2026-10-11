.VerifyGit <- function(private,
                       args) {
  suppressWarnings(
    system2(
      command = "git",
      args = c("-C", shQuote(private), args),
      stdout = TRUE,
      stderr = FALSE
    )
  )
}
