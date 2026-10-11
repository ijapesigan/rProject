#' Write the Data Manifest
#'
#' Writes `.setup/ai/data.md` (private),
#' with one row for each file in the data tiers
#' (`.setup/data-raw`, `.setup/data-private`, `.setup/data-external`):
#' the file, its tier, size, MD5, status,
#' the source and location (filled in by the user and kept on rewrite),
#' and the scripts that use it.
#'
#' External files are local only.
#' One that is listed but missing on this machine is kept,
#' marked "not on this machine";
#' one whose MD5 differs from the recorded one is marked "changed".
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @return Returns the manifest as a data frame, invisibly.
#' @export
DataManifest <- function(path) {
  manifest <- file.path(path, ".setup", "ai", "data.md")
  old <- .DataManifestRead(file = manifest)
  tiers <- c(
    raw = "data-raw",
    private = "data-private",
    external = "data-external"
  )
  rows <- lapply(
    X = names(tiers),
    FUN = function(tier) {
      dir <- file.path(path, ".setup", tiers[[tier]])
      files <- list.files(
        path = dir,
        recursive = TRUE,
        all.files = TRUE,
        no.. = TRUE
      )
      files <- files[!grepl(pattern = "(^|/)\\.gitignore$", x = files)]
      if (length(files) > 0L) {
        data.frame(
          file = file.path(".setup", tiers[[tier]], files),
          tier = tier,
          size = sprintf(
            "%.2f MB",
            file.info(file.path(dir, files))$size / 1024^2
          ),
          md5 = unname(tools::md5sum(file.path(dir, files))),
          status = "ok",
          stringsAsFactors = FALSE
        )
      }
    }
  )
  new <- do.call(what = "rbind", args = rows)
  if (is.null(new)) {
    new <- data.frame(
      file = character(0),
      tier = character(0),
      size = character(0),
      md5 = character(0),
      status = character(0),
      stringsAsFactors = FALSE
    )
  }
  # keep what the user wrote, and flag external files
  keep <- old[match(new$file, old$file), c("source", "location")]
  new$source <- ifelse(is.na(keep$source), "", keep$source)
  new$location <- ifelse(is.na(keep$location), "", keep$location)
  changed <- new$tier == "external" &
    !is.na(match(new$file, old$file)) &
    old$md5[match(new$file, old$file)] != new$md5 &
    nzchar(old$md5[match(new$file, old$file)])
  new$status[changed] <- "changed"
  gone <- old[
    old$tier == "external" & !(old$file %in% new$file), ,
    drop = FALSE
  ]
  if (nrow(gone) > 0L) {
    gone$status <- "not on this machine"
    new <- rbind(new, gone[, names(new)])
  }
  new$used_by <- .DataManifestUsedBy(path = path, files = new$file)
  .DataManifestWrite(file = manifest, data = new)
  message(
    paste0(
      "\n\nWrote ",
      manifest,
      ": ",
      nrow(new),
      " files (",
      sum(new$status != "ok"),
      " need attention).\n\n"
    )
  )
  invisible(new)
}
