#' Report the Full Texts Missing from the lib-* Library
#'
#' For each `lib-<decade>-<type>` project in `root`, lists the entries with no
#' full text in the private repository (`.setup/notes/<ext>/<repo>-<key>.<ext>`
#' in the project's `.verify`), and the files there that match no entry.
#' PDF, EPUB, and DjVu count as a full text, and so does a part (`-ch01`);
#' a supplement alone does not. A work with no copy in any format is listed in
#' `.setup/notes/no-full-text.txt` (one key per line, a reason after `#`).
#'
#' Pull each `.verify` first (`bash .setup/scripts/verify.sh` on the host).
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @param root Character string.
#'   The folder with local clones of the `lib-*` projects.
#' @return Returns a list, invisibly: `missing`, a data frame with the columns
#'   `repo`, `key`, and `status`; `orphans`, a data frame with the columns
#'   `repo` and `file`; and `unchecked`, the projects without a `.verify`.
#' @examples
#' \dontrun{
#' LibFullTextReport(root = dirname(getwd()))
#' }
#' @export
LibFullTextReport <- function(root) {
  repos <- list.files(
    path = root,
    pattern = "^lib-[0-9]{4}-[0-9]{4}-[a-z]+$"
  )
  clones <- file.path(root, repos, ".verify")
  checked <- dir.exists(paths = clones)
  results <- lapply(
    X = which(x = checked),
    FUN = function(i) {
      out <- .LibFullText(
        path = clones[i],
        private = clones[i]
      )
      entries <- out$entries[
        !(out$entries$status %in% c("ok", "exempt")), ,
        drop = FALSE
      ]
      list(
        missing = data.frame(
          repo = rep(x = repos[i], times = nrow(x = entries)),
          key = entries$key,
          status = entries$status,
          stringsAsFactors = FALSE
        ),
        orphans = data.frame(
          repo = rep(x = repos[i], times = length(x = out$orphans)),
          file = out$orphans,
          stringsAsFactors = FALSE
        ),
        entries = nrow(x = out$entries)
      )
    }
  )
  bind <- function(name, columns) {
    out <- do.call(
      what = "rbind",
      args = c(
        list(columns),
        lapply(
          X = results,
          FUN = function(x) {
            x[[name]]
          }
        )
      )
    )
    rownames(x = out) <- NULL
    out
  }
  missing_text <- bind(
    name = "missing",
    columns = data.frame(
      repo = character(length = 0),
      key = character(length = 0),
      status = character(length = 0),
      stringsAsFactors = FALSE
    )
  )
  orphans <- bind(
    name = "orphans",
    columns = data.frame(
      repo = character(length = 0),
      file = character(length = 0),
      stringsAsFactors = FALSE
    )
  )
  total <- sum(
    vapply(
      X = results,
      FUN = function(x) {
        x$entries
      },
      FUN.VALUE = integer(length = 1)
    )
  )
  message(
    paste0(
      "\n\n",
      nrow(x = missing_text),
      " of ",
      total,
      " entries have no full text; ",
      nrow(x = orphans),
      " files match no entry; ",
      sum(!checked),
      " of ",
      length(x = repos),
      " projects have no .verify (not checked).\n\n"
    )
  )
  invisible(
    x = list(
      missing = missing_text,
      orphans = orphans,
      unchecked = repos[!checked]
    )
  )
}
