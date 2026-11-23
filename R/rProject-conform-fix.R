#' Fix What Conform Can Fix
#'
#' Applies the `fix` rows of [Conform()]:
#' it writes the missing tier 1 template files and the files every package
#' has (from `reference` when it has them, else from rProject), and removes
#' the strays (`main.tex`, an empty `.tmp-r/`) from the working copy.
#' It never overwrites a file, and never touches a `decide` or `info` row.
#' Strays are removed only with `remove = TRUE`, and never a locked copy.
#' The upload folder is compared with the project (files that differ, that
#' are missing, and that are not in the manifest) and the drift is reported.
#' Then it keeps the records in step:
#' it adds a "Structure audit additions" section to the log
#' `.setup/logs/YYYY-MM-DD-<topic>.md` (made with [Log()] when there is
#' none; a fix-up with [FixUp()] when the log was already pushed, that is,
#' a row of `.setup/logs/index.md` names it with a commit),
#' and puts the new files and the log in the upload folder
#' (in place when the log was not pushed, a `-fixup` folder when it was).
#' It prints the files changed and the files to delete in Overleaf
#' (which it never does itself), and that the dot-files must be created
#' by hand in Overleaf.
#' With `lint = TRUE` or `tests = TRUE` it ends with a final re-check:
#' the real `make lint` and the unit tests, reported as in [Conform()]
#' (never run otherwise).
#' Nothing is committed or pushed.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams Conform
#' @param topic Character string.
#'   The topic of the change-set log
#'   (`.setup/logs/YYYY-MM-DD-<topic>.md`).
#' @param dest Character string or `NULL`.
#'   The folder that holds the upload folders, as in [Upload()].
#' @param remove Logical.
#'   If `TRUE`, remove the strays (`main.tex`, an empty `.tmp-r/`) from the
#'   working copy; otherwise they are only reported.
#'   A locked copy (a file in `.setup/r-dependencies/<lib>/` or
#'   `.setup/cpp/`) is never removed.
#' @param lint,tests Logical.
#'   If `TRUE`, run `make lint` or `devtools::test()` after the fixes, as in
#'   [Conform()].
#' @param log_dir Character string.
#'   The folder for the raw outputs of the final re-check.
#' @return Returns a list, invisibly, with the files written (`new`), the
#'   files to delete in Overleaf (`overleaf`), the local-only removals
#'   (`local`), the log, and the upload folder
#'   (`NULL` when there was nothing to fix), and `check`, the findings of the
#'   final re-check (`NULL` without `lint` or `tests`).
#' @examples
#' \dontrun{
#' ConformFix(path = getwd(), reference = "../devel-linearAlgebra")
#' }
#' @export
ConformFix <- function(path = ".",
                       reference = NULL,
                       topic = "conform",
                       dest = NULL,
                       remove = FALSE,
                       lint = FALSE,
                       tests = FALSE,
                       log_dir = tempdir()) {
  path <- normalizePath(path = path)
  if (!is.null(x = reference)) {
    reference <- normalizePath(path = reference)
  }
  template <- .ConformTemplate(path = path)
  rows <- .ConformRun(path = path, reference = reference, remote = FALSE)
  changes <- .ConformWrite(
    path = path,
    rows = rows,
    reference = reference,
    template = template,
    remove = remove
  )
  total <- length(x = unlist(x = changes[c("new", "overleaf", "local")]))
  if (total == 0L) {
    message("\n\nConformFix: nothing to fix.\n\n")
    out <- c(changes, list(log = NULL, folder = NULL))
  } else {
    text <- function(x) {
      ifelse(
        test = length(x = x) == 0L,
        yes = "(none)",
        no = paste(x, collapse = ", ")
      )
    }
    record <- .ConformRecord(
      path = path,
      topic = topic,
      changes = changes,
      reference = reference,
      dest = dest
    )
    message(
      paste0(
        "\n\nConformFix: ",
        path,
        "\nNew: ",
        text(x = changes$new),
        "\nDelete in Overleaf by hand: ",
        text(x = changes$overleaf),
        "\nRemoved here only: ",
        text(x = changes$local),
        ifelse(
          test = length(x = changes$kept) > 0L,
          yes = paste0(
            "\nStrays kept (use remove = TRUE to remove): ",
            text(x = changes$kept)
          ),
          no = ""
        ),
        ifelse(
          test = any(
            grepl(pattern = "^(R|tests|src|\\.setup/cpp)/", x = changes$new)
          ),
          yes = "\nFiles in R/, tests/, or .setup/cpp/ changed: run the tests.",
          no = ""
        ),
        ifelse(
          test = nrow(x = record$drift) > 0L,
          yes = paste0(
            "\nUpload folder drift:\n",
            paste(
              record$drift$file,
              record$drift$message,
              sep = ": ",
              collapse = "\n"
            )
          ),
          no = ""
        ),
        "\nLog: ",
        record$log,
        "\nUpload folder: ",
        record$folder,
        "\n\n"
      )
    )
    out <- c(changes, list(log = record$log, folder = record$folder))
  }
  check <- NULL
  if (lint || tests) {
    check <- .ConformChecks(
      path = path,
      lint = lint,
      tests = tests,
      log_dir = log_dir
    )
    message(
      paste0(
        "\nConformFix re-check (",
        nrow(x = check),
        " rows):\n",
        paste(
          utils::capture.output(
            print(
              x = check[, c("class", "rule", "file", "message")],
              row.names = FALSE,
              right = FALSE
            )
          ),
          collapse = "\n"
        ),
        "\nLogs: ",
        paste(attr(x = check, which = "logs"), collapse = ", "),
        "\n"
      )
    )
  }
  out$check <- check
  invisible(x = out)
}
