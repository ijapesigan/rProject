.PkgSnapshot <- function(path,
                         labels = "/.singularity.d/labels.json") {
  # the Posit Package Manager snapshot: RPROJECT_SNAPSHOT (GitHub Actions,
  # from the lock), the day before the running sif's date, the lock's
  # snapshot, or latest
  date <- "^\\d{4}-\\d{2}-\\d{2}$"
  candidates <- c(
    Sys.getenv(x = "RPROJECT_SNAPSHOT"),
    .SnapshotDate(created = .SifInfo(labels = labels)$created),
    .LockRead(path = path)$snapshot
  )
  candidates <- candidates[!is.na(
    x = candidates
  ) & grepl(pattern = date, x = candidates)]
  c(candidates, "latest")[1]
}
