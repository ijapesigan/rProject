#' Create a Spec
#'
#' Creates `.setup/ai/specs/YYYY-MM-DD-<topic>.md` from a template.
#' Every change set starts with a spec that the user approves.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @param topic Character string.
#'   Short topic in kebab case (e.g., `"log-spec"`).
#'   The change-set log uses the same topic.
#' @param title Character string.
#'   Title of the spec.
#' @return Returns the path of the spec invisibly.
#' @export
Spec <- function(path,
                 topic,
                 title = topic) {
  date <- format(Sys.Date())
  file <- file.path(
    path,
    ".setup",
    "ai",
    "specs",
    paste0(date, "-", topic, ".md")
  )
  if (file.exists(file)) {
    stop(
      paste0(
        "\n\n",
        file,
        " already exists.\n\n"
      ),
      call. = FALSE
    )
  }
  dir.create(
    path = dirname(file),
    showWarnings = FALSE,
    recursive = TRUE
  )
  writeLines(
    text = c(
      paste("# Spec:", title),
      "",
      paste0("Status: draft, awaiting approval (", date, ")"),
      "",
      "## Problem",
      "",
      "## Design",
      "",
      "## Files",
      "",
      "## Acceptance",
      ""
    ),
    con = file
  )
  message(
    paste0(
      "\n\nCreated ",
      file,
      "\n\n"
    )
  )
  invisible(file)
}
