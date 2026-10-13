.LibEntry <- function(record,
                      library = NULL) {
  # a draft entry from a Crossref record: type, key, repo, fields, and the
  # questions the user must answer; never invents a field
  first <- function(x) {
    if (is.null(x) || length(x) == 0L) NA_character_ else as.character(x[[1]])
  }
  ymd <- function(x) {
    parts <- unlist(x$`date-parts`)
    if (length(parts) == 0L || is.na(parts[1])) {
      NA_character_
    } else if (length(parts) >= 2L) {
      sprintf("%04d-%02d", as.integer(parts[1]), as.integer(parts[2]))
    } else {
      sprintf("%04d", as.integer(parts[1]))
    }
  }
  questions <- character(0)
  types <- c(
    "journal-article" = "Article",
    "book" = "Book",
    "monograph" = "Book",
    "edited-book" = "Book",
    "reference-book" = "Book",
    "book-chapter" = "InBook",
    "book-section" = "InBook",
    "book-part" = "InBook",
    "report" = "Report",
    "dissertation" = "Thesis",
    "posted-content" = "Unpublished"
  )
  crossref_type <- first(record$type)
  type <- c(types[crossref_type], "Misc")[1]
  if (is.na(types[crossref_type])) {
    questions <- c(
      questions,
      paste0("Crossref type '", crossref_type, "': Misc is a guess; check it.")
    )
  }
  repo_type <- switch(type,
    Article = "article",
    Unpublished = "article",
    Book = "book",
    InBook = "book",
    "manual"
  )
  # people: given and family names, accents as LaTeX
  people <- function(list) {
    vapply(
      X = list,
      FUN = function(p) {
        if (!is.null(p$name)) {
          paste0("{", .LibLatex(x = p$name), "}")
        } else {
          family <- .LibLatex(x = first(p$family), escape = FALSE)
          if (grepl(pattern = " ", x = family)) {
            family <- paste0("{", family, "}")
          }
          given <- .LibLatex(x = c(first(p$given), "")[1], escape = FALSE)
          trimws(paste(given, family))
        }
      },
      FUN.VALUE = character(1)
    )
  }
  authors <- people(list = record$author)
  editors <- people(list = record$editor)
  families <- vapply(
    X = c(record$author, if (length(record$author) == 0L) record$editor),
    FUN = function(p) c(p$family, p$name, "")[1],
    FUN.VALUE = character(1)
  )
  given <- vapply(
    X = c(record$author, record$editor),
    FUN = function(p) c(p$given, "")[1],
    FUN.VALUE = character(1)
  )
  if (any(grepl(pattern = "^([A-Z]\\.[[:space:]-]*)+$", x = given))) {
    questions <- c(
      questions,
      paste(
        "Crossref gives initials only: add full given names",
        "from the publisher, the work, or ORCID."
      )
    )
  }
  # the issue (print) date, not the online-first date
  date <- ymd(record$`published-print`)
  if (is.na(date)) date <- ymd(record$`journal-issue`$`published-print`)
  if (is.na(date)) {
    date <- ymd(record$issued)
    if (!is.null(record$`published-online`) && type == "Article") {
      questions <- c(
        questions,
        paste0(
          "No print issue yet: the date is the online date (", date, "). ",
          "Recheck the year (and key, file, repository) when the issue appears."
        )
      )
    }
  }
  year <- substr(date, 1, 4)
  decade <- paste0(
    floor(as.integer(year) / 10) * 10,
    "-",
    floor(as.integer(year) / 10) * 10 + 9
  )
  title <- first(record$title)
  subtitle <- first(record$subtitle)
  if (!is.na(subtitle)) title <- paste0(title, ": ", subtitle)
  title <- .LibTitle(x = .LibLatex(x = title))
  container <- .LibLatex(x = first(record$`container-title`))
  pages <- gsub(
    pattern = "[-\u2013]+",
    replacement = "--",
    x = first(record$page)
  )
  if (!is.na(pages) && !grepl(pattern = "--", x = pages) && type != "Book") {
    questions <- c(
      questions,
      paste(
        "Crossref gives only the first page:",
        "add the last page from the publisher or the work."
      )
    )
  }
  abstract <- first(record$abstract)
  if (!is.na(abstract)) {
    abstract <- gsub(pattern = "<[^>]+>", replacement = " ", x = abstract)
    abstract <- gsub(pattern = "[[:space:]]+", replacement = " ", x = abstract)
    abstract <- sub(
      pattern = "^[[:space:]]*Abstract[[:space:]]+",
      replacement = "",
      x = trimws(abstract)
    )
    abstract <- .LibLatex(x = abstract)
  } else {
    questions <- c(
      questions,
      paste(
        "No abstract in Crossref: look for it on the publisher's page",
        "(final version)."
      )
    )
  }
  issn <- first(record$ISSN)
  publisher <- .LibLatex(x = first(record$publisher))
  # reuse the library's ISSN and publisher for the same journal
  if (!is.null(library) && !is.na(container) && type == "Article") {
    same <- library[library$journaltitle %in% container, , drop = FALSE]
    if (nrow(same) > 0L) {
      issn <- c(same$issn[!is.na(same$issn)], issn)[1]
      publisher <- c(same$publisher[!is.na(same$publisher)], publisher)[1]
    }
  }
  fields <- c(
    author = ifelse(
      length(authors) > 0L,
      paste(authors, collapse = " and "),
      NA_character_
    ),
    editor = ifelse(
      length(editors) > 0L,
      paste(editors, collapse = " and "),
      NA_character_
    ),
    date = date,
    title = title,
    journaltitle = if (type == "Article") container else NA,
    booktitle = if (type == "InBook") container else NA,
    doi = first(record$DOI),
    issn = if (type == "Article") issn else NA,
    isbn = if (type %in% c("Book", "InBook")) first(record$ISBN) else NA,
    number = first(record$issue),
    pages = pages,
    volume = first(record$volume),
    edition = first(record$`edition-number`),
    abstract = abstract,
    publisher = publisher
  )
  fields <- fields[!is.na(fields)]
  questions <- c(
    questions,
    paste(
      "Check the title's capitalization",
      "(proper nouns stay capitalized, in braces)."
    )
  )
  key <- .LibKey(families = families, year = year)
  list(
    type = type,
    key = key,
    repo = paste0("lib-", decade, "-", repo_type),
    fields = fields,
    questions = questions
  )
}
