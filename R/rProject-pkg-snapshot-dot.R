.PkgSnapshot <- function(path,
                         labels = "/.singularity.d/labels.json") {
  # the Posit Package Manager snapshot: RPROJECT_SNAPSHOT (GitHub Actions,
  # from the lock), the running sif's date, the lock's snapshot, or latest
  date <- "^\\d{4}-\\d{2}-\\d{2}$"
  candidates <- c(
    Sys.getenv("RPROJECT_SNAPSHOT"),
    .SifInfo(labels = labels)$created,
    .LockRead(path = path)$snapshot
  )
  candidates <- candidates[!is.na(candidates) & grepl(date, candidates)]
  c(candidates, "latest")[1]
}
