.PkgGitHubNeeded <- function(installed,
                             ref = "HEAD",
                             sha = NA_character_) {
  # never upgrade (the user, 2026-10-22): install a GitHub package when it
  # is missing from every library, or when `ref` is a commit SHA that
  # differs from the installed RemoteSha; a branch or tag never reinstalls
  pinned <- grepl("^[0-9a-f]{7,40}$", ref)
  !installed || (
    pinned && (is.na(sha) || !startsWith(sha, ref))
  )
}
