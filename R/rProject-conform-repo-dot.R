.ConformRepo <- function(path,
                         remote) {
  # `.setup/repo/` against the private repository: a real repository name
  # and Overleaf URL, no placeholder text in the handoff, specs, and logs;
  # with `remote = TRUE`, read-only git calls (ls-remote, the origin URL)
  info <- .RepoInfo(path = path)
  github <- info$private_github
  overleaf <- info$private_overleaf
  folders <- c("repo", "ai", "logs")
  files <- unlist(
    x = lapply(
      X = folders,
      FUN = function(i) {
        file.path(
          ".setup",
          i,
          list.files(
            path = file.path(path, ".setup", i),
            pattern = "\\.md$",
            recursive = TRUE
          )
        )
      }
    )
  )
  files <- files[!grepl(pattern = "^\\.setup/ai/(style|global)/", x = files)]
  holder <- vapply(
    X = files,
    FUN = function(i) {
      any(
        grepl(
          pattern = "PLACEHOLDER|UNKNOWN",
          x = readLines(con = file.path(path, i), warn = FALSE)
        )
      )
    },
    FUN.VALUE = logical(length = 1),
    USE.NAMES = FALSE
  )
  bad_github <- is.na(x = github) ||
    !grepl(pattern = "^[A-Za-z0-9._-]+/[A-Za-z0-9._-]+$", x = github) ||
    grepl(pattern = "PLACEHOLDER|UNKNOWN", x = github)
  bad_overleaf <- is.na(x = overleaf) || !grepl(
    pattern = "^https://www\\.overleaf\\.com/project/[0-9a-f]{24}$",
    x = overleaf
  )
  rows <- list(
    .ConformRow(
      rule = "placeholder",
      class = "decide",
      file = files[holder],
      message = "placeholder text (PLACEHOLDER or UNKNOWN)"
    ),
    .ConformRow(
      rule = "repo",
      class = "decide",
      file = rep(x = ".setup/repo/private-github.md", times = bad_github),
      message = "no `owner/repository` of the private repository"
    ),
    .ConformRow(
      rule = "repo",
      class = "decide",
      file = rep(x = ".setup/repo/private-overleaf.md", times = bad_overleaf),
      message = "not an Overleaf project URL"
    )
  )
  if (remote && !bad_github) {
    rows <- c(rows, list(.ConformRemote(path = path, info = info)))
  }
  .ConformBind(rows = rows)
}
