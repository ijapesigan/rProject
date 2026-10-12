.ShellQuote <- function(x) {
  # quote arguments for system2() in the platform's shell
  shQuote(
    string = x,
    type = ifelse(
      test = .Platform$OS.type == "windows",
      yes = "cmd",
      no = "sh"
    )
  )
}
