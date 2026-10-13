#' Check the Entries of a lib-* Library
#'
#' Checks every entry file in `.setup/latex/bib` of a `lib-<decade>-<type>`
#' project against the house conventions.
#'
#' - **ERROR:** the file does not parse or holds more than one entry;
#'   the file name is not `<repo>-<key>.bib`;
#'   the key does not follow `Family-Family-Family[-etal]-Year[a-z]`
#'   (three names, then `etal`, for four or more authors);
#'   the key year differs from the `date` year or lies outside the decade;
#'   a required field is missing;
#'   a non-ASCII character;
#'   an unescaped `%` in a text field;
#'   a key or DOI used twice;
#'   biber reports a missing mandatory field.
#' - **WARNING:** an entry type outside the repository's type;
#'   a lone suffix (`b` without `a`); other biber datamodel warnings.
#' - **STYLE:** not in the house layout (see [LibFormat()]);
#'   `\a'`-style accents; a page range with one hyphen;
#'   a DOI with a prefix; no final newline.
#'
#' biber's warning that `publisher` is not an `@Article` field is the
#' house convention and is not reported.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @param root Character string or `NULL`.
#'   A folder with local clones of the other `lib-*` projects,
#'   to find keys and DOIs used in more than one repository.
#'   If `NULL`, only this project is checked.
#' @param error Logical.
#'   If `TRUE`, stop when there is an ERROR.
#' @return Returns a data frame with the columns
#'   `file`, `key`, `severity`, `check`, and `message`, invisibly.
#' @export
LibCheck <- function(path,
                     root = NULL,
                     error = FALSE) {
  repo <- .VerifyProject(path = path)
  parts <- regmatches(
    x = repo,
    m = regexec(pattern = "^lib-([0-9]{4})-([0-9]{4})-([a-z]+)$", text = repo)
  )[[1]]
  if (length(parts) == 0L) {
    stop(
      paste0("\n\n", repo, " is not a lib-<decade>-<type> project.\n\n"),
      call. = FALSE
    )
  }
  others <- character(0)
  if (!is.null(root)) {
    others <- list.files(
      path = root,
      pattern = "^lib-[0-9]{4}-[0-9]{4}-[a-z]+$",
      full.names = TRUE
    )
    others <- others[normalizePath(others) != normalizePath(path)]
  }
  all <- .LibRead(paths = c(path, others))
  here <- all[all$path == path, , drop = FALSE]
  finding <- function(row, severity, check, message) {
    data.frame(
      file = rep(row$file, length(severity)),
      key = rep(row$key, length(severity)),
      severity = severity,
      check = check,
      message = message,
      stringsAsFactors = FALSE
    )
  }
  rows <- lapply(
    X = seq_len(nrow(here)),
    FUN = function(i) {
      found <- .LibCheckEntry(
        row = here[i, ],
        repo = repo,
        first = as.integer(parts[2]),
        last = as.integer(parts[3]),
        repo_type = parts[4]
      )
      finding(
        row = here[i, ],
        severity = found$severity,
        check = found$check,
        message = found$message
      )
    }
  )
  # keys and DOIs used twice, and lone suffixes, across repositories
  ok <- all[all$ok, , drop = FALSE]
  dup_key <- ok$key[duplicated(ok$key)]
  doi <- tolower(ok$doi)
  dup_doi <- unique(doi[!is.na(doi) & duplicated(doi)])
  for (i in which(here$ok)) {
    row <- here[i, ]
    if (row$key %in% dup_key) {
      where <- unique(ok$repo[ok$key == row$key])
      rows <- c(
        rows,
        list(
          finding(
            row,
            "ERROR",
            "duplicate key",
            paste("also in", paste(where, collapse = ", "))
          )
        )
      )
    }
    if (!is.na(row$doi) && tolower(row$doi) %in% dup_doi) {
      keys <- setdiff(ok$key[!is.na(doi) & doi == tolower(row$doi)], row$key)
      rows <- c(
        rows,
        list(
          finding(
            row,
            "ERROR",
            "duplicate DOI",
            paste("same DOI:", paste(keys, collapse = ", "))
          )
        )
      )
    }
    stem <- sub(pattern = "([0-9]{4})[b-z]$", replacement = "\\1", x = row$key)
    if (stem != row$key && !(paste0(stem, "a") %in% ok$key)) {
      rows <- c(
        rows,
        list(finding(row, "WARNING", "suffix", paste0("no ", stem, "a")))
      )
    }
  }
  # biber's datamodel
  biber <- .LibBiber(text = here$text[here$ok])
  for (i in seq_len(nrow(biber))) {
    row <- here[here$ok & here$key == biber$key[i], , drop = FALSE]
    if (nrow(row) > 0L) {
      severity <- ifelse(
        grepl(pattern = "Missing mandatory", x = biber$message[i]),
        "ERROR",
        "WARNING"
      )
      rows <- c(
        rows,
        list(finding(row[1, ], severity, "biber", biber$message[i]))
      )
    }
  }
  out <- do.call(
    what = rbind,
    args = c(
      list(finding(here[0, ], character(0), character(0), character(0))),
      rows
    )
  )
  counts <- table(
    factor(out$severity, levels = c("ERROR", "WARNING", "STYLE"))
  )
  message(
    paste0(
      "\n\nLibCheck ", repo, ": ", nrow(here), " files; ",
      counts[["ERROR"]], " errors, ", counts[["WARNING"]], " warnings, ",
      counts[["STYLE"]], " style",
      ifelse(
        is.null(root),
        " (this repository only; pass root for keys and DOIs used twice)",
        ""
      ),
      ".\n\n"
    )
  )
  if (error && counts[["ERROR"]] > 0L) {
    errors <- out[out$severity == "ERROR", , drop = FALSE]
    stop(
      paste0(
        "\n\n",
        paste0(errors$file, ": ", errors$message, collapse = "\n"),
        "\n\n"
      ),
      call. = FALSE
    )
  }
  invisible(out)
}
