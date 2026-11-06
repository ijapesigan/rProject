.VerifyGit <- function(private,
                       args) {
  suppressWarnings(
    expr = system2(
      command = "git",
      args = c("-C", .ShellQuote(x = private), args),
      stdout = TRUE,
      stderr = FALSE
    )
  )
}
