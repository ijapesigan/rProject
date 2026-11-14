.ConformUpload <- function(path,
                           template) {
  # tier 2 files in the project's upload folders (fix: removed from the
  # folder; a pushed folder is only reported), and tier 2 files in the
  # pushed private repository (.verify; delete in Overleaf is optional)
  project <- .VerifyProject(path = path)
  dest <- .UploadDest(path = path)
  folders <- list.files(
    path = dest,
    pattern = paste0("^[0-9]{4}-[0-9]{2}-[0-9]{2}-", project, "-")
  )
  logs <- list.files(
    path = file.path(path, ".setup", "logs"),
    pattern = "^[0-9]{4}-[0-9]{2}-[0-9]{2}-.*\\.md$"
  )
  rows <- lapply(
    X = folders,
    FUN = function(folder) {
      files <- list.files(
        path = file.path(dest, folder),
        all.files = TRUE,
        recursive = TRUE
      )
      keep <- .UploadSet(path = path, files = files, template = template)
      files <- files[!keep]
      topic <- sub(
        pattern = paste0("^[0-9-]{10}-", project, "-(.*?)(-fixup)?$"),
        replacement = "\\1",
        x = folder
      )
      stems <- sub(pattern = "^[0-9-]{10}-", replacement = "", x = logs)
      log <- logs[stems == paste0(topic, ".md")]
      pushed <- length(x = log) > 0L && any(
        vapply(
          X = log,
          FUN = function(one) {
            .ConformPushed(path = path, log = one)
          },
          FUN.VALUE = logical(length = 1)
        )
      )
      pushed <- pushed || grepl(pattern = "-fixup$", x = folder)
      .ConformRow(
        rule = "upload-tier2",
        class = ifelse(test = pushed, yes = "info", no = "fix"),
        file = file.path(folder, files),
        message = ifelse(
          test = pushed,
          yes = "tier 2 file in a pushed upload folder (the folder is final)",
          no = "tier 2 file in an upload folder (make writes it)"
        ),
        fix = ifelse(test = pushed, yes = "", no = "remove-upload")
      )
    }
  )
  verify <- file.path(path, ".verify")
  pushed_files <- character(length = 0)
  if (dir.exists(paths = verify)) {
    pushed_files <- list.files(
      path = verify,
      all.files = TRUE,
      recursive = TRUE
    )
    git <- startsWith(x = pushed_files, prefix = ".git/")
    pushed_files <- pushed_files[!git]
    pushed_files <- pushed_files[
      !.UploadSet(path = path, files = pushed_files, template = template)
    ]
  }
  rows <- c(
    rows,
    list(
      .ConformRow(
        rule = "pushed-tier2",
        class = "info",
        file = pushed_files,
        message = paste(
          "tier 2 file in the pushed repository",
          "(delete in Overleaf is optional; make regenerates it)"
        )
      )
    )
  )
  .ConformBind(rows = rows)
}
