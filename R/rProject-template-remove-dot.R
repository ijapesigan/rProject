.TemplateRemove <- function(path,
                            root,
                            check) {
  # files the template no longer has (inst/template/removed.tsv):
  # a file row (a path or a glob) is deleted; a folder row (ending in /)
  # is deleted only when nothing but .gitignore files is left in it;
  # nothing in a private folder is touched
  removed <- utils::read.delim(
    file = file.path(root, "removed.tsv"),
    colClasses = "character"
  )
  folders <- .TemplateFolders(root = root)
  private <- folders$folder[folders$private]
  rows <- removed$path[
    !vapply(
      X = removed$path,
      FUN = function(x) {
        any(startsWith(x = x, prefix = private))
      },
      FUN.VALUE = logical(length = 1)
    )
  ]
  is_folder <- grepl(pattern = "/$", x = rows)
  # plan first, then delete (check = TRUE only plans)
  deleted <- character(length = 0)
  for (row in rows[!is_folder]) {
    hits <- Sys.glob(paths = file.path(path, row))
    hits <- hits[!dir.exists(paths = hits)]
    deleted <- c(deleted, substring(text = hits, first = nchar(x = path) + 2L))
  }
  files <- deleted
  # deepest folders first, so that a parent sees its children as gone
  folder_rows <- rows[is_folder]
  folder_rows <- folder_rows[order(-nchar(x = folder_rows))]
  gone <- character(length = 0)
  kept <- character(length = 0)
  for (row in folder_rows) {
    if (dir.exists(paths = file.path(path, row))) {
      inside <- file.path(
        sub(pattern = "/$", replacement = "", x = row),
        list.files(
          path = file.path(path, row),
          all.files = TRUE,
          recursive = TRUE,
          no.. = TRUE
        )
      )
      left <- setdiff(x = inside, y = deleted)
      if (all(basename(path = left) == ".gitignore")) {
        deleted <- c(deleted, left)
        gone <- c(gone, row)
      } else {
        kept <- c(kept, row)
      }
    }
  }
  if (!check) {
    unlink(x = file.path(path, files))
    unlink(x = file.path(path, gone), recursive = TRUE)
  }
  deleted <- unique(x = deleted)
  if (length(x = deleted) > 0L) {
    message(
      paste0(
        "\n\n",
        ifelse(
          test = check,
          yes = "Template files to delete",
          no = "Template files deleted"
        ),
        " (no longer in the template; delete them in Overleaf too):\n",
        paste(deleted, collapse = "\n"),
        "\n\n"
      )
    )
  }
  if (length(x = kept) > 0L) {
    message(
      paste0(
        "\n\nNot deleted (they hold files the template does not know;",
        " move or delete them by hand):\n",
        paste(kept, collapse = "\n"),
        "\n\n"
      )
    )
  }
  deleted
}
