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
#' @examples
#' \dontrun{
#' DataManifest(path = getwd())
#' }
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
    X = names(x = tiers),
    FUN = function(tier) {
      dir <- file.path(path, ".setup", tiers[[tier]])
      files <- list.files(
        path = dir,
        recursive = TRUE,
        all.files = TRUE,
        no.. = TRUE
      )
      files <- files[!grepl(pattern = "(^|/)\\.gitignore$", x = files)]
      if (length(x = files) > 0L) {
        data.frame(
          file = file.path(".setup", tiers[[tier]], files),
          tier = tier,
          size = sprintf(
            fmt = "%.2f MB",
            file.info(file.path(dir, files))$size / 1024^2
          ),
          md5 = unname(obj = tools::md5sum(files = file.path(dir, files))),
          status = "ok",
          stringsAsFactors = FALSE
        )
      }
    }
  )
  new <- do.call(what = "rbind", args = rows)
  if (is.null(x = new)) {
    new <- data.frame(
      file = character(length = 0),
      tier = character(length = 0),
      size = character(length = 0),
      md5 = character(length = 0),
      status = character(length = 0),
      stringsAsFactors = FALSE
    )
  }
  # keep what the user wrote, and flag external files
  keep <- old[match(x = new$file, table = old$file), c("source", "location")]
  new$source <- ifelse(
    test = is.na(x = keep$source),
    yes = "",
    no = keep$source
  )
  new$location <- ifelse(
    test = is.na(x = keep$location),
    yes = "",
    no = keep$location
  )
  changed <- new$tier == "external" &
    !is.na(x = match(x = new$file, table = old$file)) &
    old$md5[match(x = new$file, table = old$file)] != new$md5 &
    nzchar(x = old$md5[match(x = new$file, table = old$file)])
  new$status[changed] <- "changed"
  gone <- old[
    old$tier == "external" & !(old$file %in% new$file), ,
    drop = FALSE
  ]
  if (nrow(x = gone) > 0L) {
    gone$status <- "not on this machine"
    new <- rbind(new, gone[, names(x = new)])
  }
  new$used_by <- .DataManifestUsedBy(path = path, files = new$file)
  .DataManifestWrite(file = manifest, data = new)
  message(
    paste0(
      "\n\nWrote ",
      manifest,
      ": ",
      nrow(x = new),
      " files (",
      sum(new$status != "ok"),
      " need attention).\n\n"
    )
  )
  invisible(x = new)
}
