#' Build the Upload Folder of a Change Set
#'
#' Copies the files that the change-set log lists as new or edited
#' to `<dest>/YYYY-MM-DD-<project>-<topic>[-fixup]/`, at their paths
#' in the project, so the folder can be uploaded to Overleaf as it is.
#' Generated files, linked files, and the commit message are not in it.
#' The deletions are printed, to be done by hand in Overleaf.
#' An existing folder is never touched:
#' upload folders are final, and a later change is a fix-up ([FixUp()]).
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams Log
#' @param fixup Logical.
#'   If `TRUE`, use the lists of the newest fix-up section of the log
#'   and name the folder `...-fixup`.
#'   Otherwise, use the lists of the change set itself.
#' @param dest Character string.
#'   The folder that holds the upload folders.
#'   By default `/scratch/ibp5092/Work/upload` when it exists (Roar),
#'   else `upload` next to the projects.
#' @return Returns the path of the upload folder invisibly.
#' @examples
#' \dontrun{
#' Upload(path = getwd(), topic = "my-topic")
#' }
#' @export
Upload <- function(path,
                   topic,
                   fixup = FALSE,
                   dest = NULL) {
  path <- normalizePath(path = path)
  logs <- file.path(path, ".setup", "logs")
  existing <- sort(
    x = list.files(
      path = logs,
      pattern = paste0("^[0-9]{4}-[0-9]{2}-[0-9]{2}-", topic, "\\.md$")
    ),
    decreasing = TRUE
  )
  if (length(x = existing) == 0L) {
    stop(
      paste0("\n\nNo log for topic \"", topic, "\" in ", logs, ".\n\n"),
      call. = FALSE
    )
  }
  log_file <- file.path(logs, existing[1])
  lines <- readLines(
    con = log_file,
    warn = FALSE
  )
  subject <- .UploadSubject(
    lines = lines,
    fixup = fixup
  )
  if (is.na(x = subject)) {
    stop(
      paste0(
        "\n\n",
        log_file,
        " has no ",
        ifelse(test = fixup, yes = "fix-up", no = "commit message"),
        " block.\n\n"
      ),
      call. = FALSE
    )
  }
  project <- .VerifyProject(path = path)
  listed <- .VerifyLogFiles(
    log_file = log_file,
    project = project,
    subject = subject
  )
  if (is.null(x = dest)) {
    dest <- .UploadDest(path = path)
  }
  folder <- file.path(
    dest,
    paste0(
      .LogDate(),
      "-",
      project,
      "-",
      topic,
      ifelse(test = fixup, yes = "-fixup", no = "")
    )
  )
  if (file.exists(folder)) {
    stop(
      paste0(
        "\n\n",
        folder,
        " already exists. Upload folders are final: use `fixup = TRUE`",
        " (after `FixUp()`) or another topic.\n\n"
      ),
      call. = FALSE
    )
  }
  files <- listed$file[listed$action == "upload"]
  delete <- listed$file[listed$action == "delete"]
  files <- files[!grepl(pattern = "^TODO$", x = files)]
  present <- file.exists(file.path(path, files))
  for (file in files[present]) {
    target <- file.path(folder, file)
    dir.create(
      path = dirname(path = target),
      showWarnings = FALSE,
      recursive = TRUE
    )
    file.copy(
      from = file.path(path, file),
      to = target
    )
  }
  if (!dir.exists(paths = folder)) {
    dir.create(
      path = folder,
      recursive = TRUE
    )
  }
  message(
    paste0(
      "\n\nUpload folder: ",
      folder,
      "\n",
      sum(present),
      " file(s) copied.",
      ifelse(
        test = all(present),
        yes = "",
        no = paste0(
          "\nListed but not found (not copied): ",
          paste(files[!present], collapse = ", ")
        )
      ),
      ifelse(
        test = length(x = delete) > 0L,
        yes = paste0(
          "\nDelete in Overleaf by hand: ",
          paste(delete, collapse = ", ")
        ),
        no = ""
      ),
      "\n\n"
    )
  )
  invisible(x = folder)
}
