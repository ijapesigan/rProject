.GitRemoteRepo <- function(remote) {
  # owner/repo from any remote form (https, git@github.com:, an SSH alias)
  sub(
    pattern = "^.*[:/]([^/:]+/[^/:]+)$",
    replacement = "\\1",
    x = sub(pattern = "\\.git/?$|/$", replacement = "", x = remote)
  )
}
