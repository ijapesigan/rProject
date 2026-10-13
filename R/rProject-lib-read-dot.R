.LibRead <- function(paths) {
  # every .bib entry file in the given lib-* projects, one row per file
  rows <- lapply(
    X = paths,
    FUN = function(path) {
      repo <- .VerifyProject(path = path)
      files <- list.files(
        path = file.path(path, ".setup", "latex", "bib"),
        pattern = "\\.bib$",
        full.names = TRUE
      )
      files <- files[basename(files) != "bib.bib"]
      lapply(
        X = files,
        FUN = function(file) {
          raw <- readBin(con = file, what = "raw", n = file.info(file)$size)
          text <- rawToChar(raw[raw != as.raw(0)])
          entry <- .LibParse(text = text)
          field <- function(name) {
            unname(c(entry$fields[name], NA_character_)[1])
          }
          data.frame(
            repo = repo,
            path = path,
            file = basename(file),
            n = entry$n,
            ok = entry$ok,
            error = entry$error,
            type = entry$type,
            key = entry$key,
            author = field("author"),
            editor = field("editor"),
            date = c(field("date"), field("year"))[
              ifelse(is.na(field("date")), 2L, 1L)
            ],
            journaltitle = field("journaltitle"),
            title = field("title"),
            doi = field("doi"),
            issn = field("issn"),
            publisher = field("publisher"),
            ascii = all(as.integer(raw) < 128L),
            newline = length(raw) > 0L && raw[length(raw)] == as.raw(10L),
            text = text,
            stringsAsFactors = FALSE
          )
        }
      )
    }
  )
  rows <- unlist(rows, recursive = FALSE)
  if (length(rows) == 0L) {
    data.frame()
  } else {
    do.call(what = rbind, args = rows)
  }
}
