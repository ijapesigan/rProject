.SnapshotDate <- function(created) {
  # the Posit Package Manager snapshot for an image built on `created`
  # (UTC): the day before. An image installs the newest packages when it
  # is built, which is the previous day's snapshot; a day's own snapshot
  # is published only after that day ends, so the image's date may not
  # exist yet (CI then cannot install anything).
  out <- rep(
    x = NA_character_,
    times = length(x = created)
  )
  ok <- !is.na(x = created) & grepl(
    pattern = "^\\d{4}-\\d{2}-\\d{2}$",
    x = created
  )
  out[ok] <- format(
    x = as.Date(x = created[ok]) - 1L,
    format = "%Y-%m-%d"
  )
  out
}
