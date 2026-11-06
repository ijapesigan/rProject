.LockSha256 <- function(file) {
  out <- suppressWarnings(
    expr = system2(
      command = "sha256sum",
      args = shQuote(string = file),
      stdout = TRUE,
      stderr = FALSE
    )
  )
  ifelse(
    test = length(x = out) == 1 && is.null(x = attr(x = out, which = "status")),
    yes = sub(pattern = "\\s.*$", replacement = "", x = out),
    no = NA_character_
  )
}
