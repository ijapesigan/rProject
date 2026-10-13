.LibBiber <- function(text) {
  # biber's datamodel warnings for the entries in `text`, one row each;
  # none when biber is not installed
  out <- data.frame(
    key = character(0),
    message = character(0),
    stringsAsFactors = FALSE
  )
  if (length(text) > 0L && nzchar(Sys.which("biber"))) {
    dir <- tempfile(pattern = "biber")
    dir.create(dir)
    on.exit(unlink(dir, recursive = TRUE), add = TRUE)
    bib <- file.path(dir, "check.bib")
    writeLines(text = text, con = bib)
    log <- suppressWarnings(
      system2(
        command = "biber",
        args = c(
          "--tool",
          "--validate-datamodel",
          paste0("--output-file=", .ShellQuote(x = file.path(dir, "out.bib"))),
          .ShellQuote(x = bib)
        ),
        stdout = TRUE,
        stderr = TRUE
      )
    )
    hits <- grep(pattern = "^WARN - Datamodel: ", x = log, value = TRUE)
    # the house keeps publisher in @Article
    hits <- hits[
      !grepl(
        pattern = "Invalid field 'publisher' for entrytype 'article'",
        x = hits,
        fixed = TRUE
      )
    ]
    if (length(hits) > 0L) {
      out <- data.frame(
        key = sub(
          pattern = "^WARN - Datamodel: [A-Za-z]+ entry '([^']+)'.*$",
          replacement = "\\1",
          x = hits
        ),
        message = sub(pattern = "^.*\\): ", replacement = "", x = hits),
        stringsAsFactors = FALSE
      )
    }
  }
  out
}
