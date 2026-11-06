.PublicRemote <- function(path) {
  # make auto commits and pushes to the origin of `path`: it must be the public
  # repository, whatever clone.sh did. A folder without a remote has no push.
  origin <- character(length = 0)
  if (file.exists(file.path(path, ".git"))) {
    origin <- .VerifyGit(
      private = path,
      args = c("remote", "get-url", "origin")
    )
  }
  if (length(x = origin) == 1L) {
    info <- .RepoInfo(path = path)
    repo <- .GitRemoteRepo(remote = origin)
    problem <- NA_character_
    if (attr(x = info, which = "public_none")) {
      problem <- paste0(
        ".setup/repo/public-github.md says this project has no public",
        " repository, but origin is ",
        repo
      )
    } else if (is.na(x = info$public_github)) {
      problem <- paste0(
        "origin is ",
        repo,
        ", and .setup/repo/public-github.md is missing or empty:",
        " add the public repository (owner/repo) there"
      )
    } else if (tolower(x = repo) != tolower(x = info$public_github)) {
      problem <- paste0(
        "origin is ",
        repo,
        ", but the public repository is ",
        info$public_github
      )
    }
    if (!is.na(x = problem)) {
      stop(
        paste0(
          "\n\nThe remote of ",
          path,
          " is not the public repository. Nothing was published:\n- ",
          problem,
          "\n\nRun make auto in a copy without .git, so that clone.sh brings",
          " in the public .git.\n\n"
        ),
        call. = FALSE
      )
    }
  }
  invisible(x = NULL)
}
