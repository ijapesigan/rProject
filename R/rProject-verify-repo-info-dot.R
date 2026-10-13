.VerifyRepoInfo <- function(path,
                            private) {
  info <- .RepoInfo(path = path)
  files <- c(
    private_github = "private-github.md",
    private_overleaf = "private-overleaf.md",
    public_github = "public-github.md"
  )
  missing <- files[
    vapply(
      X = names(files),
      FUN = function(x) {
        is.na(info[[x]]) && !(x == "public_github" && attr(info, "public_none"))
      },
      FUN.VALUE = logical(1)
    )
  ]
  warn <- character(0)
  fail <- character(0)
  if (length(missing) > 0L) {
    warn <- paste(
      "missing in .setup/repo/:",
      paste(missing, collapse = ", ")
    )
  }
  # a share link grants access: only the project URL belongs here
  overleaf <- info$private_overleaf
  if (
    !is.na(overleaf) &&
      !grepl(
        pattern = "^https://www\\.overleaf\\.com/project/[0-9a-f]+/?$",
        x = overleaf
      )
  ) {
    fail <- "private-overleaf.md is not an Overleaf project URL (a share link?)"
  }
  # the private clone's remote
  remote <- .VerifyGit(
    private = private,
    args = c("remote", "get-url", "origin")
  )
  # owner/repo from any remote form (https, git@github.com:, an SSH alias)
  remote <- sub(
    pattern = "^.*[:/]([^/:]+/[^/:]+)$",
    replacement = "\\1",
    x = sub(pattern = "\\.git$", replacement = "", x = remote)
  )
  if (
    !is.na(info$private_github) &&
      length(remote) == 1L &&
      !identical(remote, info$private_github)
  ) {
    warn <- c(
      warn,
      paste0(
        "private-github.md says ",
        info$private_github,
        "; .verify is ",
        remote
      )
    )
  }
  clone <- .RepoInfoClone(path = path)
  if (
    !is.na(info$public_github) &&
      !is.na(clone) &&
      clone != info$public_github
  ) {
    warn <- c(
      warn,
      paste0(
        "public-github.md says ",
        info$public_github,
        "; clone.sh clones ",
        clone
      )
    )
  }
  status <- "pass"
  if (length(warn) > 0L) {
    status <- "warn"
  }
  if (length(fail) > 0L) {
    status <- "fail"
  }
  detail <- paste(c(fail, warn), collapse = "; ")
  if (!nzchar(detail)) {
    detail <- paste(
      c(info$private_github, info$private_overleaf, info$public_github),
      collapse = ", "
    )
  }
  c(status = status, detail = detail)
}
