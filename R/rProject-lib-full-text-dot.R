.LibFullText <- function(path,
                         private) {
  # the full text of each entry: .setup/notes/<ext>/<repo>-<key>[.-]... in the
  # private clone (the local project usually lacks these files: they are
  # uploaded in Overleaf)
  bib <- list.files(
    path = file.path(path, ".setup", "latex", "bib"),
    pattern = "^lib-.*\\.bib$"
  )
  notes <- file.path(private, ".setup", "notes")
  folders <- list.dirs(path = notes, full.names = FALSE, recursive = FALSE)
  # as.character: a project with no .setup/notes yet has no files at all
  files <- as.character(
    x = unlist(
      x = lapply(
        X = folders,
        FUN = function(folder) {
          list.files(path = file.path(notes, folder))
        }
      )
    )
  )
  files <- files[!grepl(pattern = "^\\.", x = files)]
  # the key of an exempted work: the first word of a line; a reason after #
  exempt <- character(length = 0)
  exempt_file <- file.path(notes, "no-full-text.txt")
  if (file.exists(exempt_file)) {
    exempt <- trimws(
      x = sub(
        pattern = "#.*$",
        replacement = "",
        x = readLines(con = exempt_file, warn = FALSE)
      )
    )
    exempt <- exempt[nzchar(x = exempt)]
  }
  stems <- sub(pattern = "\\.bib$", replacement = "", x = bib)
  matched <- lapply(
    X = stems,
    FUN = function(stem) {
      files[
        startsWith(x = files, prefix = paste0(stem, ".")) |
          startsWith(x = files, prefix = paste0(stem, "-"))
      ]
    }
  )
  keys <- sub(
    pattern = "^lib-[0-9]{4}-[0-9]{4}-[a-z]+-",
    replacement = "",
    x = stems
  )
  # pdf, epub, and djvu count; a part counts, a supplement alone does not
  counts <- function(x) {
    grepl(pattern = "\\.(pdf|epub|djvu)$", x = x, ignore.case = TRUE) &
      !grepl(pattern = "-(suppl|appendix)[^/]*$", x = x, ignore.case = TRUE)
  }
  status <- vapply(
    X = seq_along(along.with = stems),
    FUN = function(i) {
      x <- matched[[i]]
      if (any(counts(x = x))) {
        "ok"
      } else if (keys[i] %in% exempt) {
        "exempt"
      } else if (any(grepl(pattern = "\\.docx$", x = x, ignore.case = TRUE))) {
        "docx only: convert to PDF"
      } else {
        "missing"
      }
    },
    FUN.VALUE = character(length = 1)
  )
  entries <- data.frame(
    key = keys,
    file = bib,
    files = vapply(
      X = matched,
      FUN = paste,
      FUN.VALUE = character(length = 1),
      collapse = ", "
    ),
    has_full_text = status == "ok",
    status = status,
    stringsAsFactors = FALSE
  )
  rownames(x = entries) <- NULL
  orphans <- setdiff(
    x = files,
    y = unlist(x = matched)
  )
  orphans <- orphans[orphans != "no-full-text.txt"]
  list(
    entries = entries,
    orphans = orphans
  )
}
