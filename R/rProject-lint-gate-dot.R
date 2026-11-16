#' Stop on Line Length Findings in Package Projects
#'
#' The public CI runs `lintr` with `LINTR_ERROR_ON_LINT: true`:
#' a line over 80 characters fails the job.
#' `Lint()` only printed such findings,
#' so `make lint`, `make all`, and `make auto` passed
#' and the failure showed up on GitHub after the release.
#' This gate stops `Lint()` on a `line_length_linter` finding
#' in a package project (types `cran` and `rProject`,
#' which include the source libraries).
#' `LINTR_ERROR_ON_LINT=false` switches it off.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @param lints Output of `lintr::lint_dir()`.
#' @param type Character string or `NULL`. The template type.
#'
#' @return Returns `lints`, invisibly, or stops.
#'
#' @family Lint Functions
#' @keywords rProject lint internal
#' @noRd
.LintGate <- function(lints,
                      type) {
  off <- identical(
    x = tolower(
      x = Sys.getenv(
        x = "LINTR_ERROR_ON_LINT",
        unset = "true"
      )
    ),
    y = "false"
  )
  package <- !is.null(x = type) && type %in% c("cran", "rProject")
  if (package && !off && length(x = lints) > 0L) {
    long <- Filter(
      f = function(lint) {
        identical(x = lint$linter, y = "line_length_linter")
      },
      x = lints
    )
    if (length(x = long) > 0L) {
      print(x = lints)
      where <- vapply(
        X = long,
        FUN = function(lint) {
          paste0(lint$filename, ":", lint$line_number)
        },
        FUN.VALUE = character(length = 1L)
      )
      stop(
        paste0(
          "\n\n",
          length(x = long),
          " line(s) over 80 characters; the public CI fails on them.\n",
          paste(
            utils::head(x = where, n = 20L),
            collapse = "\n"
          ),
          ifelse(
            test = length(x = where) > 20L,
            yes = "\n...",
            no = ""
          ),
          "\n\nWrap them (LINTR_ERROR_ON_LINT=false skips this check).\n\n"
        ),
        call. = FALSE
      )
    }
  }
  invisible(x = lints)
}
