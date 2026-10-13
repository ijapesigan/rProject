#' Put the Entries of a lib-* Library in the House Layout
#'
#' Rewrites each entry file in `.setup/latex/bib` of a `lib-*` project
#' in the house layout, without changing what the entry says:
#'
#' - `@Type{Key,`, then one `  field = {value},` per line, then `}`,
#'   and a final newline;
#' - fields in the house order: `author`, `editor`, `bookauthor`,
#'   `booktitle`, `date`, `journaltitle`, `title`, `subtitle`,
#'   the other fields alphabetically, then `abstract`, `publisher`,
#'   `keywords`, `library`, and `annotation`;
#' - field names in lower case and entry types in the house spelling
#'   (`Article`, `InBook`, `PhdThesis`, ...);
#' - `\a'`-style accents as `\'` (`{\a'e}` becomes `{\'e}`);
#' - page ranges with `--`;
#' - DOIs without a `https://doi.org/` or `doi:` prefix.
#'
#' Files that do not parse, or that hold more than one entry,
#' are left as they are (see [LibCheck()]).
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @param write Logical.
#'   If `TRUE`, rewrite the files that change.
#'   If `FALSE`, only report them.
#' @return Returns the names of the files that change (or changed),
#'   invisibly.
#' @export
LibFormat <- function(path,
                      write = FALSE) {
  files <- list.files(
    path = file.path(path, ".setup", "latex", "bib"),
    pattern = "\\.bib$",
    full.names = TRUE
  )
  files <- files[basename(files) != "bib.bib"]
  changed <- character(0)
  for (file in files) {
    lines <- readLines(con = file, warn = FALSE)
    text <- paste0(paste(lines, collapse = "\n"), "\n")
    entry <- .LibParse(text = text)
    if (entry$ok && entry$n == 1L) {
      fields <- entry$fields
      # \a'e -> \'e (the form RefManageR wrote)
      fields[] <- gsub(
        pattern = "\\\\a([^A-Za-z])",
        replacement = "\\\\\\1",
        x = fields
      )
      if (!is.na(fields["pages"])) {
        fields["pages"] <- gsub(
          pattern = "([0-9A-Za-z])[[:space:]]*-[[:space:]]*([0-9A-Za-z])",
          replacement = "\\1--\\2",
          x = fields["pages"]
        )
      }
      if (!is.na(fields["doi"])) {
        fields["doi"] <- sub(
          pattern = "^(https?://(dx\\.)?doi\\.org/|doi:)",
          replacement = "",
          x = fields["doi"],
          ignore.case = TRUE
        )
      }
      new <- paste0(
        paste(
          .LibFormat(type = entry$type, key = entry$key, fields = fields),
          collapse = "\n"
        ),
        "\n"
      )
      raw <- readChar(con = file, nchars = file.info(file)$size)
      if (!identical(new, text) || !grepl(pattern = "\n$", x = raw)) {
        changed <- c(changed, basename(file))
        if (write) {
          writeLines(
            text = sub(pattern = "\n$", replacement = "", x = new),
            con = file
          )
        }
      }
    }
  }
  message(
    paste0(
      "\n\nLibFormat ", .VerifyProject(path = path), ": ",
      length(changed), " of ", length(files), " files ",
      ifelse(write, "rewritten", "would change"),
      ".\n\n"
    )
  )
  invisible(changed)
}
