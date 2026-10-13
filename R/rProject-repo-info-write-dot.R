.RepoInfoWrite <- function(path) {
  repo <- file.path(path, ".setup", "repo")
  written <- character(0)
  if (!dir.exists(repo)) {
    dir.create(repo, recursive = TRUE)
    writeLines(text = c("*", "*/"), con = file.path(repo, ".gitignore"))
    writeLines(
      text = paste0("jeksterslab-psu/", .VerifyProject(path = path)),
      con = file.path(repo, "private-github.md")
    )
    written <- file.path(repo, c(".gitignore", "private-github.md"))
    # the public repository that clone.sh clones
    public <- .RepoInfoClone(path = path)
    if (!is.na(public)) {
      writeLines(text = public, con = file.path(repo, "public-github.md"))
      written <- c(written, file.path(repo, "public-github.md"))
    }
    message(
      paste0(
        "\n\nCreated ",
        repo,
        ". Add the Overleaf project URL",
        " (https://www.overleaf.com/project/<id>) to private-overleaf.md,",
        " and check the GitHub repositories.\n\n"
      )
    )
  }
  invisible(written)
}
