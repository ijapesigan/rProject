#' Verify an Overleaf Push
#'
#' Checks a push from Overleaf to the private GitHub repository
#' against the change-set log in `.setup/logs`.
#'
#' The checks, and when each fails:
#'
#' - **New commit:** the commit is already recorded in `index.md`
#'   (`.verify` is stale, or there was no new push). Nothing is recorded.
#' - **Listed files:** a file listed under "Files to update in Overleaf"
#'   is missing from or differs in the private repository.
#' - **Deletions:** a file listed under "Delete in Overleaf"
#'   is still in the private repository.
#' - **Unlisted changes:** (warning only) other files differ
#'   between the project and the private repository.
#' - **Commit message:** (warning only) the last commit message
#'   does not end with `Log: .setup/logs/<log>`.
#' - **Secrets:** [SecretScan()] finds a token in the private repository.
#' - **Public export:** a file that `make auto` would publish is private
#'   (e.g., `.setup/ai/`, `.setup/logs/`, `AGENTS.md`)
#'   or larger than 50 MB.
#'
#' Generated files (e.g., `NAMESPACE`, `man/`),
#' local folders (e.g., `.library`),
#' and secret files are never compared.
#'
#' The private repository must be cloned on the host,
#' because SSH keys are not available in the container.
#' `.setup/scripts/verify.sh` clones or pulls it into `.verify`
#' (local only; never uploaded) and then calls `Verify()`.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @param private Character string.
#'   Path to a clone of the private repository at the pushed commit.
#'   By default `.verify` in the project.
#' @param log Character string.
#'   File name of the change-set log in `.setup/logs`.
#'   If `NULL`, the newest log with a pending push in `.setup/logs/index.md`.
#' @param record Logical.
#'   If `TRUE`, write the commit and the result
#'   in the log's "Pushes" table and in `.setup/logs/index.md`.
#' @param error Logical.
#'   If `TRUE`, stop with an error when a check fails.
#' @return Returns a data frame of checks
#'   with the columns `check`, `status`, and `detail`.
#' @export
Verify <- function(path,
                   private = file.path(path, ".verify"),
                   log = NULL,
                   record = FALSE,
                   error = TRUE) {
  if (is.null(log)) {
    log <- .VerifyLogPending(path = path)
  }
  log_file <- file.path(
    path,
    ".setup",
    "logs",
    log
  )
  if (!file.exists(log_file)) {
    stop(
      paste0(
        "\n\n",
        log_file,
        " does not exist.\n\n"
      ),
      call. = FALSE
    )
  }
  listed <- .VerifyLogFiles(
    log_file = log_file,
    project = .VerifyProject(path = path)
  )
  upload <- listed$file[listed$action == "upload"]
  delete <- listed$file[listed$action == "delete"]
  # listed files
  upload_status <- vapply(
    X = upload,
    FUN = function(file) {
      .VerifyCompare(
        path = path,
        private = private,
        file = file
      )
    },
    FUN.VALUE = character(1)
  )
  upload_bad <- upload_status != "match"
  # deletions
  delete_bad <- file.exists(file.path(private, delete))
  # unlisted changes
  unlisted <- .VerifyUnlisted(
    path = path,
    private = private,
    listed = listed$file
  )
  # commit message
  sha <- .VerifyGit(
    private = private,
    args = c("rev-parse", "--short", "HEAD")
  )
  message_body <- .VerifyGit(
    private = private,
    args = c("log", "-1", "--format=%B")
  )
  # a commit already in index.md means a stale clone or no new push
  recorded <- .VerifyRecorded(
    path = path,
    sha = sha
  )
  log_line <- paste0("Log: .setup/logs/", log)
  message_ok <- any(trimws(message_body) == log_line)
  # secrets
  secrets <- suppressMessages(
    suppressWarnings(
      SecretScan(
        path = private,
        error = FALSE
      )
    )
  )
  # public export
  public <- .VerifyPublic(private = private)
  checks <- data.frame(
    check = c(
      "New commit",
      "Listed files",
      "Deletions",
      "Unlisted changes",
      "Commit message",
      "Secrets",
      "Public export"
    ),
    status = c(
      ifelse(recorded, "fail", "pass"),
      ifelse(any(upload_bad), "fail", "pass"),
      ifelse(any(delete_bad), "fail", "pass"),
      ifelse(length(unlisted) > 0L, "warn", "pass"),
      ifelse(message_ok, "pass", "warn"),
      ifelse(nrow(secrets) > 0L, "fail", "pass"),
      ifelse(length(public) > 0L, "fail", "pass")
    ),
    detail = c(
      ifelse(
        recorded,
        paste(
          sha,
          "is already in index.md: .verify is stale or there is no new push",
          "(pull with bash .setup/scripts/verify.sh)"
        ),
        sha
      ),
      ifelse(
        any(upload_bad),
        paste(upload[upload_bad], upload_status[upload_bad], collapse = "; "),
        paste(length(upload), "files match")
      ),
      ifelse(
        any(delete_bad),
        paste("still present:", paste(delete[delete_bad], collapse = "; ")),
        paste(length(delete), "files removed")
      ),
      ifelse(
        length(unlisted) > 0L,
        paste(unlisted, collapse = "; "),
        "none"
      ),
      ifelse(
        message_ok,
        log_line,
        paste("missing", log_line)
      ),
      ifelse(
        nrow(secrets) > 0L,
        paste(unique(secrets$file), collapse = "; "),
        "none found"
      ),
      ifelse(
        length(public) > 0L,
        paste(public, collapse = "; "),
        "no private or oversized files"
      )
    ),
    stringsAsFactors = FALSE
  )
  failed <- checks$status == "fail"
  result <- ifelse(
    any(failed),
    paste(
      "\u2717 Verify():",
      paste(checks$check[failed], collapse = ", "),
      "failed"
    ),
    paste0(
      "\u2713 Verify(): all checks pass",
      ifelse(
        any(checks$status == "warn"),
        paste0(
          " (warnings: ",
          paste(checks$check[checks$status == "warn"], collapse = ", "),
          ")"
        ),
        ""
      )
    )
  )
  report <- paste0(
    "\n\nVerify ",
    log,
    " against ",
    sha,
    ":\n",
    paste0(
      "[",
      checks$status,
      "] ",
      checks$check,
      ": ",
      checks$detail,
      collapse = "\n"
    ),
    "\n",
    result,
    "\n\n"
  )
  if (record && recorded) {
    message("\n\nNot recorded: ", sha, " is already in index.md.\n\n")
  }
  if (record && !recorded) {
    .VerifyRecord(
      path = path,
      log = log,
      sha = sha,
      result = result
    )
  }
  if (any(failed) && error) {
    stop(
      report,
      call. = FALSE
    )
  } else {
    message(report)
  }
  invisible(checks)
}
