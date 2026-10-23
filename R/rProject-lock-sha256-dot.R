.LockSha256 <- function(file) {
  out <- suppressWarnings(
    system2(
      command = "sha256sum",
      args = shQuote(file),
      stdout = TRUE,
      stderr = FALSE
    )
  )
  ifelse(
    length(out) == 1 && is.null(attr(out, "status")),
    sub("\\s.*$", "", out),
    NA_character_
  )
}
