#' Library Tags
#'
#' Lists the key, `annotation`, and `keywords` of every entry in the
#' project's Quarto bibliography (`.setup/quarto/bib/quarto.bib`, written
#' by [Bib()]), for the "Library Tags" page of the Quarto site.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @return Returns a data frame with the columns `key`, `annotation`,
#'   and `keywords` (`NA` when an entry has none), sorted by key.
#'   Without the bibliography, an empty data frame, with a message.
#' @examples
#' \dontrun{
#' Tags(path = getwd())
#' }
#' @export
Tags <- function(path) {
  bib <- file.path(path, ".setup", "quarto", "bib", "quarto.bib")
  out <- data.frame(
    key = character(length = 0),
    annotation = character(length = 0),
    keywords = character(length = 0)
  )
  if (file.exists(bib)) {
    entries <- lapply(
      X = .LibSplit(
        text = readLines(con = bib, warn = FALSE, encoding = "UTF-8")
      ),
      FUN = .LibParse
    )
    entries <- entries[
      vapply(X = entries, FUN = `[[`, "ok", FUN.VALUE = logical(length = 1))
    ]
    if (length(x = entries) > 0L) {
      field <- function(entry, name) {
        unname(obj = c(entry$fields[name], NA_character_)[1])
      }
      out <- data.frame(
        key = vapply(
          X = entries,
          FUN = `[[`,
          "key",
          FUN.VALUE = character(length = 1)
        ),
        annotation = vapply(
          X = entries,
          FUN = field,
          name = "annotation",
          FUN.VALUE = character(length = 1)
        ),
        keywords = vapply(
          X = entries,
          FUN = field,
          name = "keywords",
          FUN.VALUE = character(length = 1)
        )
      )
      out <- out[order(out$key), ]
      rownames(x = out) <- NULL
    }
  } else {
    message(paste0("\n\nTags(): no ", bib, ".\nRun make bib.\n\n"))
  }
  out
}
