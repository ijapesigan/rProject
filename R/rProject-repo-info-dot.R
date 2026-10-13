.RepoInfo <- function(path) {
  read <- function(file) {
    file <- file.path(path, ".setup", "repo", file)
    value <- character(0)
    if (file.exists(file)) {
      value <- trimws(readLines(con = file, warn = FALSE))
      value <- value[nzchar(value)]
    }
    c(value, NA_character_)[1]
  }
  info <- list(
    private_github = read(file = "private-github.md"),
    private_overleaf = read(file = "private-overleaf.md"),
    public_github = read(file = "public-github.md")
  )
  # "none": the project has no public copy, on purpose
  none <- identical(info$public_github, "none")
  if (none) {
    info$public_github <- NA_character_
  }
  attr(info, "public_none") <- none
  info
}
