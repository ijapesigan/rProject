.LibCheckEntry <- function(row,
                           repo,
                           first,
                           last,
                           repo_type) {
  # the checks of one entry file (a row of .LibRead()); one row per finding
  out <- data.frame(
    severity = character(0),
    check = character(0),
    message = character(0),
    stringsAsFactors = FALSE
  )
  add <- function(out, severity, check, message) {
    rbind(
      out,
      data.frame(
        severity = severity,
        check = check,
        message = message,
        stringsAsFactors = FALSE
      )
    )
  }
  allowed <- list(
    article = c("Article", "Unpublished"),
    book = c("Book", "InBook", "InCollection"),
    manual = c(
      "Manual", "Misc", "Report", "Online", "Software", "Dataset",
      "Thesis", "PhdThesis", "MastersThesis", "Unpublished"
    )
  )
  required <- list(
    Article = c("author", "date", "journaltitle", "title"),
    Book = c("date", "title", "publisher"),
    InBook = c("author", "booktitle", "date", "title", "publisher"),
    InCollection = c("author", "booktitle", "date", "title", "publisher"),
    Unpublished = c("author", "date", "title")
  )
  if (!row$ok) {
    out <- add(out, "ERROR", "parse", paste("does not parse:", row$error))
  } else {
    fields <- .LibParse(text = row$text)$fields
    if (row$n != 1L) {
      out <- add(out, "ERROR", "one entry", paste(row$n, "entries in one file"))
    }
    expected <- paste0(repo, "-", row$key, ".bib")
    if (row$file != expected) {
      out <- add(out, "ERROR", "file name", paste("expected", expected))
    }
    # the key
    pattern <- "^[A-Za-z]+(-[A-Za-z]+){0,2}(-etal)?-[0-9]{4}[a-z]?$"
    people <- c(fields["author"], fields["editor"])
    people <- people[!is.na(people)][1]
    if (!grepl(pattern = pattern, x = row$key)) {
      out <- add(
        out,
        "ERROR",
        "key",
        "not Family-Family-Family[-etal]-Year[a-z]"
      )
    } else if (!is.na(people)) {
      n_people <- length(.LibNames(x = people))
      names_in_key <- strsplit(
        x = sub(pattern = "-[0-9]{4}[a-z]?$", replacement = "", x = row$key),
        split = "-"
      )[[1]]
      etal <- "etal" %in% names_in_key
      good <- ifelse(
        n_people >= 4L,
        etal && length(names_in_key) == 4L,
        !etal && length(names_in_key) == n_people
      )
      if (!good) {
        out <- add(
          out,
          "ERROR",
          "key",
          paste(
            n_people,
            "authors: expected",
            ifelse(
              n_people >= 4L,
              "three names and etal",
              paste(n_people, "names")
            )
          )
        )
      }
    }
    # the year, the decade, and the type
    key_year <- as.integer(
      sub(pattern = "^.*-([0-9]{4})[a-z]?$", replacement = "\\1", x = row$key)
    )
    date_year <- suppressWarnings(as.integer(substr(row$date, 1, 4)))
    if (is.na(date_year)) {
      out <- add(out, "ERROR", "date", "no date or year")
    } else {
      if (!is.na(key_year) && key_year != date_year) {
        out <- add(
          out,
          "ERROR",
          "year",
          paste0("key year ", key_year, ", date ", row$date)
        )
      }
      if (date_year < first || date_year > last) {
        out <- add(
          out,
          "ERROR",
          "decade",
          paste0(date_year, " is outside ", first, "-", last)
        )
      }
    }
    if (!(row$type %in% allowed[[repo_type]])) {
      out <- add(
        out,
        "WARNING",
        "type",
        paste0("@", row$type, " in a ", repo_type, " repository")
      )
    }
    # required fields
    need <- required[[row$type]]
    if (is.null(need)) {
      need <- c("date", "title")
    }
    missing <- need[!(need %in% names(fields))]
    creators <- c("author", "editor", "organization")
    if (!("author" %in% need) && !any(creators %in% names(fields))) {
      missing <- c(missing, "author or editor")
    }
    if (length(missing) > 0L) {
      out <- add(
        out,
        "ERROR",
        "required",
        paste("missing:", paste(unique(missing), collapse = ", "))
      )
    }
    # text
    if (!row$ascii) {
      out <- add(out, "ERROR", "ASCII", "non-ASCII characters")
    }
    text_fields <- fields[!(names(fields) %in% c("doi", "url", "eprint"))]
    percent <- names(text_fields)[
      grepl(pattern = "(^|[^\\\\])%", x = text_fields)
    ]
    if (length(percent) > 0L) {
      out <- add(
        out,
        "ERROR",
        "percent",
        paste("unescaped % in", paste(percent, collapse = ", "))
      )
    }
    # style
    if (!row$newline) {
      out <- add(out, "STYLE", "newline", "no final newline")
    }
    if (grepl(pattern = "\\\\a[^A-Za-z]", x = row$text)) {
      out <- add(out, "STYLE", "accents", "\\a-style accents")
    }
    pages <- unname(fields["pages"])
    if (
      !is.na(pages) &&
        grepl(
          pattern = "[0-9A-Za-z][[:space:]]*-[[:space:]]*[0-9A-Za-z]",
          x = pages
        )
    ) {
      out <- add(out, "STYLE", "pages", "page range with one hyphen")
    }
    if (
      !is.na(row$doi) &&
        grepl(pattern = "^(https?://|doi:)", x = row$doi, ignore.case = TRUE)
    ) {
      out <- add(out, "STYLE", "doi", "DOI with a prefix")
    }
    layout <- paste0(
      paste(
        .LibFormat(type = row$type, key = row$key, fields = fields),
        collapse = "\n"
      ),
      "\n"
    )
    if (!identical(layout, row$text)) {
      out <- add(out, "STYLE", "layout", "not in the house layout (LibFormat)")
    }
  }
  out
}
