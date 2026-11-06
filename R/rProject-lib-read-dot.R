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
      files <- files[basename(path = files) != "bib.bib"]
      lapply(
        X = files,
        FUN = function(file) {
          raw <- readBin(con = file, what = "raw", n = file.info(file)$size)
          # CRLF (a Windows checkout) is not a layout difference
          text <- gsub(
            pattern = "\r\n",
            replacement = "\n",
            x = rawToChar(x = raw[raw != as.raw(x = 0)]),
            fixed = TRUE
          )
          entry <- .LibParse(text = text)
          field <- function(name) {
            unname(obj = c(entry$fields[name], NA_character_)[1])
          }
          data.frame(
            repo = repo,
            path = path,
            file = basename(path = file),
            n = entry$n,
            ok = entry$ok,
            error = entry$error,
            type = entry$type,
            key = entry$key,
            author = field("author"),
            editor = field("editor"),
            date = c(field("date"), field("year"))[
              ifelse(test = is.na(x = field("date")), yes = 2L, no = 1L)
            ],
            journaltitle = field("journaltitle"),
            title = field("title"),
            doi = field("doi"),
            issn = field("issn"),
            publisher = field("publisher"),
            ascii = all(as.integer(x = raw) < 128L),
            newline = length(
              x = raw
            ) > 0L && raw[length(x = raw)] == as.raw(x = 10L),
            text = text,
            stringsAsFactors = FALSE
          )
        }
      )
    }
  )
  rows <- unlist(x = rows, recursive = FALSE)
  if (length(x = rows) == 0L) {
    data.frame()
  } else {
    do.call(what = rbind, args = rows)
  }
}
