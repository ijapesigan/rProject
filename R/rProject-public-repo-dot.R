.PublicRepo <- function(path) {
  # locally .setup/repo/public-github.md (private); in GitHub Actions, where
  # that file is not exported, GITHUB_REPOSITORY; NA for no public copy
  file <- file.path(
    path,
    ".setup",
    "repo",
    "public-github.md"
  )
  public <- character(length = 0)
  if (file.exists(file)) {
    public <- trimws(
      x = readLines(
        con = file,
        warn = FALSE
      )
    )
    public <- public[nzchar(x = public)]
  }
  if (length(x = public) == 0) {
    public <- Sys.getenv(x = "GITHUB_REPOSITORY")
  }
  public <- public[1]
  if (!grepl(pattern = "^[^/[:space:]]+/[^/[:space:]]+$", x = public)) {
    public <- NA_character_
  }
  public
}
