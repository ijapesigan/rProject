#' Create or Update a Change-Set Log
#'
#' Creates `.setup/logs/YYYY-MM-DD-<topic>.md`,
#' the log for one change set (one Overleaf push),
#' and adds a pending row to `.setup/logs/index.md`.
#' The log has the commit message skeleton,
#' a "Pushes" table,
#' and the list of files to update in Overleaf.
#'
#' The file lists come from comparing the project
#' with a clone of the private repository
#' (by default `.verify`, kept by `.setup/scripts/verify.sh`),
#' using the same rules as [Verify()].
#' Without a clone, the lists hold `TODO`.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams Spec
#' @inheritParams Verify
#' @param summary Character string.
#'   First line of the commit message.
#' @param update Logical.
#'   If `TRUE`, refresh only the file lists of the newest existing log
#'   for `topic`.
#' @return Returns the path of the log invisibly.
#' @export
Log <- function(path,
                topic,
                summary = topic,
                private = file.path(path, ".verify"),
                update = FALSE) {
  if (!nzchar(summary)) {
    summary <- topic
  }
  logs <- file.path(path, ".setup", "logs")
  dir.create(
    path = logs,
    showWarnings = FALSE,
    recursive = TRUE
  )
  existing <- sort(
    list.files(
      path = logs,
      pattern = paste0("^[0-9]{4}-[0-9]{2}-[0-9]{2}-", topic, "\\.md$")
    ),
    decreasing = TRUE
  )
  if (update) {
    if (length(existing) == 0L) {
      stop(
        paste0("\n\nNo log for topic \"", topic, "\" in ", logs, ".\n\n"),
        call. = FALSE
      )
    }
    log <- existing[1]
  } else {
    log <- paste0(format(Sys.Date()), "-", topic, ".md")
  }
  log_file <- file.path(logs, log)
  if (!update && file.exists(log_file)) {
    stop(
      paste0(
        "\n\n",
        log_file,
        " already exists. Use `update = TRUE`.\n\n"
      ),
      call. = FALSE
    )
  }
  if (!dir.exists(file.path(private, ".git"))) {
    private <- NULL
  }
  if (!update) {
    .LogIndex(
      path = path,
      log = log,
      summary = summary
    )
  }
  section <- .LogSection(
    path = path,
    private = private,
    log = log
  )
  if (update) {
    lines <- readLines(
      con = log_file,
      warn = FALSE
    )
    start <- which(lines == "## Files to update in Overleaf")[1]
    if (is.na(start)) {
      stop(
        paste0(
          "\n\n",
          log_file,
          " has no \"## Files to update in Overleaf\" section.\n\n"
        ),
        call. = FALSE
      )
    }
    after <- which(grepl(pattern = "^## ", x = lines))
    end <- c(after[after > start], length(lines) + 1L)[1]
    lines <- c(
      lines[seq_len(start - 1L)],
      section,
      lines[seq(from = end, length.out = length(lines) - end + 1L)]
    )
  } else {
    lines <- .LogTemplate(
      path = path,
      log = log,
      topic = topic,
      summary = summary,
      section = section
    )
  }
  writeLines(
    text = lines,
    con = log_file
  )
  message(
    paste0(
      "\n\n",
      ifelse(update, "Updated ", "Created "),
      log_file,
      ifelse(
        is.null(private),
        "\nNo clone of the private repository: file lists are TODO.",
        ""
      ),
      "\n\n"
    )
  )
  invisible(log_file)
}
