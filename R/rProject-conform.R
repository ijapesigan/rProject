#' Check a Project Against the rProject Standard
#'
#' Compares a project with the rProject standard and returns what differs
#' as a data frame (and prints it as a table).
#' The checks reuse rProject's own rules:
#' the manifest and the folders of the project's type
#' (`inst/template/manifest.tsv`, `folders.tsv`, [Tree()]),
#' the file set of a finished `reference` project,
#' the stray files Overleaf leaves (`main.tex`, `.tmp-r/`),
#' the files every package has but the manifest does not keep
#' (`vignettes/.gitignore`, `inst/CITATION`, `tests/testthat.R`,
#' `.setup/pkgdown/_pkgdown.yml`),
#' the test file of each export (`test-<pkg>-<name>.R`, as `make lint`
#' names it), the file names and one function per file (locked copies from
#' `.setup/r-dependencies/` and `.setup/cpp/` are exempt),
#' `lint_error <- FALSE`, the missing `rproject.lock`,
#' and `.setup/repo/` (placeholder text, repository name, Overleaf URL).
#' A `.gitignore` that Overleaf renamed to `gitignore` is accepted.
#' A finding that the `reference` has too is not reported.
#'
#' Each finding has a `class`:
#' `fix` (safe; [ConformFix()] writes or removes it),
#' `decide` (ambiguous: the user decides),
#' and `info` (expected, for example before the first release).
#' With `lint = TRUE`, it also runs the project's real `make lint`
#' (which runs `make style` first: files may change, read them again)
#' and, with `tests = TRUE`, `devtools::test()` with `NOT_CRAN=true`,
#' both in the R that runs `Conform()` (no Apptainer call), and reports each
#' house row, each `style:` or `warning:` message of `lintr`, and each test
#' failure or error as a `decide` row (rule `lint` or `tests`).
#' The counts of the tests are always a row.
#' The raw outputs are saved in `log_dir` and the paths are printed.
#' Nothing else is changed.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @param path Character string.
#'   The project folder.
#' @param reference Character string or `NULL`.
#'   The folder of a finished project to compare the file set with.
#'   With `NULL`, only the manifest and the rules are used.
#' @param remote Logical.
#'   If `TRUE`, also ask GitHub (`git ls-remote`, read-only) whether the
#'   private repository named in `.setup/repo/` exists, and compare the
#'   `origin` of the clone.
#'   Skipped quietly without git, ssh, or a network.
#' @param lint Logical.
#'   If `TRUE`, run the project's `make lint` and report its findings.
#' @param tests Logical.
#'   If `TRUE`, run `devtools::test()` and report its failures and counts.
#' @param log_dir Character string.
#'   The folder for the raw outputs of `make lint` and the tests
#'   (`conform-lint.log`, `conform-tests.log`); a temporary folder by default.
#' @return Returns a data frame, invisibly, with the columns `rule`, `class`
#'   (`"fix"`, `"decide"`, or `"info"`), `file`, `message`, and `fix`
#'   (how [ConformFix()] fixes a `fix` row).
#'   The attribute `logs` names the saved outputs of `lint` and `tests`.
#' @examples
#' \dontrun{
#' Conform(path = getwd())
#' Conform(path = getwd(), reference = "../linearAlgebra")
#' Conform(path = getwd(), lint = TRUE, tests = TRUE)
#' }
#' @export
Conform <- function(path = ".",
                    reference = NULL,
                    remote = FALSE,
                    lint = FALSE,
                    tests = FALSE,
                    log_dir = tempdir()) {
  path <- normalizePath(path = path)
  if (!is.null(x = reference)) {
    reference <- normalizePath(path = reference)
  }
  rows <- .ConformRun(path = path, reference = reference, remote = remote)
  type <- attr(x = rows, which = "type")
  logs <- character(length = 0)
  if (lint || tests) {
    checks <- .ConformChecks(
      path = path,
      lint = lint,
      tests = tests,
      log_dir = log_dir
    )
    logs <- attr(x = checks, which = "logs")
    rows <- .ConformBind(rows = list(rows, checks))
  }
  counts <- table(
    factor(x = rows$class, levels = c("fix", "decide", "info"))
  )
  table_text <- if (nrow(x = rows) > 0L) {
    paste0(
      "\n",
      paste(
        utils::capture.output(
          print(
            x = rows[, c("class", "rule", "file", "message")],
            row.names = FALSE,
            right = FALSE
          )
        ),
        collapse = "\n"
      )
    )
  } else {
    "\nNothing to report."
  }
  message(
    paste0(
      "\n\nConform: ",
      path,
      " (",
      type,
      ")\n",
      counts[["fix"]],
      " fix, ",
      counts[["decide"]],
      " decide, ",
      counts[["info"]],
      " info",
      table_text,
      ifelse(
        test = length(x = logs) > 0L,
        yes = paste0("\nLogs: ", paste(logs, collapse = ", ")),
        no = ""
      ),
      "\n\n"
    )
  )
  attr(x = rows, which = "type") <- NULL
  attr(x = rows, which = "logs") <- logs
  invisible(x = rows)
}
