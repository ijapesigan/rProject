.LibCrossref <- function(doi) {
  # the Crossref record of a DOI (a list), or NULL when it cannot be read
  url <- paste0(
    "https://api.crossref.org/works/",
    utils::URLencode(URL = doi, reserved = FALSE)
  )
  record <- tryCatch(
    expr = jsonlite::fromJSON(txt = url, simplifyVector = FALSE),
    error = function(e) NULL
  )
  record$message
}
