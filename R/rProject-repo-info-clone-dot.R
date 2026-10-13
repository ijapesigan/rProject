.RepoInfoClone <- function(path) {
  # owner/repo of the public repository that .setup/scripts/clone.sh clones
  clone <- file.path(path, ".setup", "scripts", "clone.sh")
  public <- character(0)
  if (file.exists(clone)) {
    lines <- readLines(con = clone, warn = FALSE)
    public <- regmatches(
      x = lines,
      m = regexpr(
        pattern = "github\\.com[:/][A-Za-z0-9._-]+/[A-Za-z0-9._-]+",
        text = lines
      )
    )
    public <- sub(pattern = "^github\\.com[:/]", replacement = "", x = public)
    public <- sub(pattern = "\\.git$", replacement = "", x = public)
  }
  c(public, NA_character_)[1]
}
