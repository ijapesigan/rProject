#' Add an Entry to the lib-* Library from a DOI
#'
#' Drafts a biblatex entry from the DOI's Crossref record,
#' in the house layout, and names the repository and file it belongs in:
#'
#' - the entry type and the repository type from the Crossref type;
#' - `date` from the print issue (`published-print`),
#'   else the journal issue, else the first publication;
#'   the key year and the decade repository follow it;
#' - names and text with LaTeX accents, and `\%` and `\&` escaped;
#' - the key as `Family-Family-Family[-etal]-Year`, accents dropped;
#' - the abstract without its JATS tags;
#' - the ISSN and publisher reused from the library's other entries
#'   for the same journal;
#' - the title in a sentence-case draft.
#'
#' It never invents a field: what Crossref does not have is left out.
#' It lists what it cannot decide (initials only, an online-first date,
#' a missing abstract, the title's proper nouns, a key already in use)
#' as questions for the user.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @param doi Character string. The DOI.
#' @param root Character string.
#'   The folder with local clones of the `lib-*` projects.
#' @param key Character string or `NULL`.
#'   A key to use instead of the drafted one (e.g., with a suffix).
#' @param title Character string or `NULL`.
#'   A title to use instead of the drafted one.
#' @param fields Named character vector or `NULL`.
#'   Fields to set or replace (e.g., full author names or an abstract
#'   from the publisher's page).
#' @param write Logical.
#'   If `TRUE`, write the file and run [LibCheck()] on its repository.
#' @return Returns a list with `file`, `text`, and `questions`, invisibly.
#' @export
LibAdd <- function(doi,
                   root,
                   key = NULL,
                   title = NULL,
                   fields = NULL,
                   write = FALSE) {
  record <- .LibCrossref(doi = doi)
  if (is.null(record)) {
    stop(
      paste0("\n\nCrossref has no record for ", doi, ".\n\n"),
      call. = FALSE
    )
  }
  repos <- list.files(
    path = root,
    pattern = "^lib-[0-9]{4}-[0-9]{4}-[a-z]+$",
    full.names = TRUE
  )
  library <- .LibRead(paths = repos)
  entry <- .LibEntry(record = record, library = library)
  if (!is.null(key)) entry$key <- key
  if (!is.null(title)) entry$fields["title"] <- title
  if (!is.null(fields)) entry$fields[names(fields)] <- fields
  questions <- entry$questions
  if (nrow(library) > 0L) {
    same_doi <- library[
      !is.na(library$doi) & tolower(library$doi) == tolower(doi), ,
      drop = FALSE
    ]
    if (nrow(same_doi) > 0L) {
      stop(
        paste0(
          "\n\n", doi, " is already in the library: ",
          paste0(same_doi$repo, "/", same_doi$file, collapse = ", "),
          "\n\n"
        ),
        call. = FALSE
      )
    }
    stem <- sub(pattern = "[a-z]$", replacement = "", x = entry$key)
    taken <- library$key[
      library$key == stem |
        grepl(pattern = paste0("^", stem, "[a-z]$"), x = library$key)
    ]
    if (length(taken) > 0L) {
      questions <- c(
        questions,
        paste0(
          "The key is taken (", paste(taken, collapse = ", "), "): ",
          "choose a suffix; renaming an existing key breaks its citations."
        )
      )
    }
  }
  text <- .LibFormat(type = entry$type, key = entry$key, fields = entry$fields)
  file <- file.path(
    root,
    entry$repo,
    ".setup",
    "latex",
    "bib",
    paste0(entry$repo, "-", entry$key, ".bib")
  )
  message(
    paste0(
      "\n\n", file, "\n\n",
      paste(text, collapse = "\n"),
      "\n\nQuestions:\n",
      paste0("- ", questions, collapse = "\n"),
      "\n\n"
    )
  )
  if (write) {
    if (!dir.exists(file.path(root, entry$repo))) {
      stop(
        paste0("\n\n", entry$repo, " is not in ", root, ".\n\n"),
        call. = FALSE
      )
    }
    writeLines(text = text, con = file)
    LibCheck(path = file.path(root, entry$repo), root = root)
  }
  invisible(list(file = file, text = text, questions = questions))
}
