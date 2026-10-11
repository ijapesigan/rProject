.DataManifestWrite <- function(file,
                               data) {
  dir.create(
    path = dirname(file),
    showWarnings = FALSE,
    recursive = TRUE
  )
  rows <- paste0(
    "| `",
    data$file,
    "` | ",
    data$tier,
    " | ",
    data$size,
    " | ",
    data$md5,
    " | ",
    data$status,
    " | ",
    data$source,
    " | ",
    data$location,
    " | ",
    data$used_by,
    " |"
  )
  writeLines(
    text = c(
      "# Data manifest",
      "",
      "Written by `rProject::DataManifest()` (`make manifest`). Private.",
      "Fill in **Source** and **Location**; they are kept when the manifest",
      "is rewritten. External files are local only: Location says where",
      "the copy lives.",
      "",
      paste0(
        "| File | Tier | Size | MD5 | Status | Source | Location | ",
        "Used by |"
      ),
      "|---|---|---|---|---|---|---|---|",
      rows[seq_len(nrow(data))]
    ),
    con = file
  )
  invisible(file)
}
