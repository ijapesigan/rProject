.VerifyLogMessage <- function(private) {
  # the log named in the pushed commit message ("Log: .setup/logs/<log>")
  body <- .VerifyGit(
    private = private,
    args = c("log", "-1", "--format=%B")
  )
  body <- trimws(body)
  hit <- regmatches(
    x = body,
    m = regexpr(pattern = "^Log: \\.setup/logs/[^ ]+\\.md$", text = body)
  )
  hit <- sub(pattern = "^Log: \\.setup/logs/", replacement = "", x = hit)
  c(hit, NA_character_)[1]
}
