#' Check the Public Export
#'
#' Checks the working tree that `make auto` is about to publish
#' (after `clone.sh` swaps in the public `.git`):
#' no private files (e.g., `.setup/ai/`, `.setup/logs/`, `AGENTS.md`),
#' no file larger than 50 MB,
#' and no tokens ([SecretScan()]) in the files that would be published.
#' `make auto` calls `Public()` before `git add`,
#' so a failed check stops the push.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @return Returns the files that would be published, invisibly.
#' @export
Public <- function(path) {
  exported <- .PublicExport(root = path)
  problems <- .VerifyPublic(private = path)
  # tokens in files that stay private (e.g., gitignored) are not published
  secrets <- suppressMessages(
    suppressWarnings(
      SecretScan(
        path = path,
        error = FALSE
      )
    )
  )
  secrets <- secrets[secrets$file %in% exported, , drop = FALSE]
  problems <- c(
    problems,
    paste0(secrets$file, ":", secrets$line, " (", secrets$type, ")")[
      seq_len(nrow(secrets))
    ]
  )
  if (length(problems) > 0L) {
    stop(
      paste0(
        "\n\nThe public export of ",
        path,
        " is not safe. Nothing was published:\n",
        paste0("- ", problems, collapse = "\n"),
        "\n\nFix .gitignore or remove the files, then rerun make auto.\n\n"
      ),
      call. = FALSE
    )
  }
  message(
    paste0(
      "\n\nPublic export of ",
      path,
      ": ",
      length(exported),
      " files; no private files, no files over 50 MB, no tokens.\n\n"
    )
  )
  invisible(exported)
}
