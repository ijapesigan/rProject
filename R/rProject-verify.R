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
#'   between the project and the private repository
#'   (`.setup/notes/claude.txt`, the resume commands, and `.setup/todo/`,
#'   the user's to-do list, are not counted).
#' - **Commit message:** (warning only) the last commit message
#'   does not end with `Log: .setup/logs/<log>`.
#' - **Secrets:** [SecretScan()] finds a token in the private repository.
#' - **Public export:** a file that `make auto` would publish is private
#'   (e.g., `.setup/ai/`, `.setup/logs/`, `.setup/repo/`, `AGENTS.md`)
#'   or larger than 50 MB.
#' - **Repo info:** `.setup/repo/private-overleaf.md` is not an Overleaf
#'   project URL (for example, a share link, which grants access).
#'   Warning only: a file in `.setup/repo/` is missing,
#'   `private-github.md` differs from the `.verify` remote,
#'   or `public-github.md` differs from the repository in `clone.sh`.
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
#'   If `NULL`, the newest log with a pending push in `.setup/logs/index.md`,
#'   else the log named in the pushed commit message
#'   (`Log: .setup/logs/<log>`), as for a fix-up push.
#' @param record Logical.
#'   If `TRUE`, write the commit and the result
#'   in the log's "Pushes" table and in `.setup/logs/index.md`,
#'   filling the pending row, or adding a row when there is none.
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
  if (is.na(log)) {
    # a fix-up push: no pending row, but the commit message names the log
    log <- .VerifyLogMessage(private = private)
  }
  if (is.na(log)) {
    stop(
      paste0(
        "\n\nNo pending push in ",
        file.path(path, ".setup", "logs", "index.md"),
        ", and the last commit message has no",
        " \"Log: .setup/logs/<log>\" line. Pass `log`.\n\n"
      ),
      call. = FALSE
    )
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
  # where the project lives
  repo_info <- .VerifyRepoInfo(
    path = path,
    private = private
  )
  checks <- data.frame(
    check = c(
      "New commit",
      "Listed files",
      "Deletions",
      "Unlisted changes",
      "Commit message",
      "Secrets",
      "Public export",
      "Repo info"
    ),
    status = c(
      ifelse(recorded, "fail", "pass"),
      ifelse(any(upload_bad), "fail", "pass"),
      ifelse(any(delete_bad), "fail", "pass"),
      ifelse(length(unlisted) > 0L, "warn", "pass"),
      ifelse(message_ok, "pass", "warn"),
      ifelse(nrow(secrets) > 0L, "fail", "pass"),
      ifelse(length(public) > 0L, "fail", "pass"),
      repo_info[["status"]]
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
      ),
      repo_info[["detail"]]
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
      result = result,
      summary = c(message_body, "")[1]
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
