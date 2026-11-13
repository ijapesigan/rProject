#' Add a Fix-Up to a Change-Set Log
#'
#' A fix-up is a small push after a change set was logged
#' (the upload folder is final, so a later change is a new push).
#' `FixUp()` appends a `## Fix-up: <summary>` section
#' to the newest log for `topic`:
#' the commit message skeleton (ending `Log: .setup/logs/<log>`)
#' and the lists of files to update in Overleaf,
#' compared with the clone of the private repository
#' (the same rules as [Log()]).
#' It also adds a pending row to the log's "Pushes" table
#' (in the order of the table's header)
#' and a pending row to `.setup/logs/index.md`.
#' After the push, [Verify()] with `record = TRUE` fills them in.
#' [Upload()] with `fixup = TRUE` builds the upload folder.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams Log
#' @param summary Character string.
#'   First line of the fix-up's commit message.
#' @return Returns the path of the log invisibly.
#' @examples
#' \dontrun{
#' FixUp(path = getwd(), topic = "my-topic", summary = "Fix-up: handoff")
#' }
#' @export
FixUp <- function(path,
                  topic,
                  summary,
                  private = file.path(path, ".verify")) {
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
  if (!nzchar(x = summary)) {
    stop(
      "\n\n`summary` is the first line of the commit message.\n\n",
      call. = FALSE
    )
  }
  log <- existing[1]
  log_file <- file.path(logs, log)
  if (!dir.exists(paths = file.path(private, ".git"))) {
    private <- NULL
  }
  section <- .LogSection(
    path = path,
    private = private,
    log = log
  )
  # one level down: the lists belong to the fix-up's section
  section <- sub(pattern = "^(#+) ", replacement = "\\1# ", x = section)
  lines <- readLines(
    con = log_file,
    warn = FALSE
  )
  pushes <- .VerifyRecordSection(
    lines = lines,
    heading = "## Pushes"
  )
  row <- .VerifyRecordRow(
    header = pushes$header,
    sha = "(pending)",
    date = "",
    result = ""
  )
  lines <- .VerifyRecordInsert(
    lines = lines,
    heading = "## Pushes",
    row = row,
    last = TRUE
  )
  lines <- c(
    lines,
    "",
    paste0("## Fix-up: ", summary),
    "",
    "```",
    summary,
    "",
    "- TODO",
    "",
    paste0("Log: .setup/logs/", log),
    "```",
    "",
    section
  )
  writeLines(
    text = lines,
    con = log_file
  )
  .LogIndex(
    path = path,
    log = log,
    summary = summary
  )
  message(
    paste0(
      "\n\nAdded a fix-up to ",
      log_file,
      ifelse(
        test = is.null(x = private),
        yes = "\nNo clone of the private repository: file lists are TODO.",
        no = ""
      ),
      "\n\n"
    )
  )
  invisible(x = log_file)
}
