.LibPubMed <- function(doi) {
  # the PubMed record of a DOI: list(pmid, xml), or NULL when PubMed does not
  # have exactly one record that carries this DOI or cannot be reached.
  # Only the DOI is sent.
  base <- "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/"
  search <- tryCatch(
    expr = jsonlite::fromJSON(
      txt = paste0(
        base,
        "esearch.fcgi?db=pubmed&retmode=json&term=",
        utils::URLencode(URL = doi, reserved = TRUE),
        "%5BAID%5D"
      ),
      simplifyVector = TRUE
    ),
    error = function(e) {
      NULL
    }
  )
  pmid <- search$esearchresult$idlist
  if (length(x = pmid) != 1L) {
    NULL
  } else {
    xml <- tryCatch(
      expr = paste(
        readLines(
          con = paste0(
            base,
            "efetch.fcgi?db=pubmed&retmode=xml&id=",
            pmid
          ),
          warn = FALSE,
          encoding = "UTF-8"
        ),
        collapse = "\n"
      ),
      error = function(e) {
        NULL
      }
    )
    found <- !is.null(x = xml) && grepl(
      pattern = paste0(
        "<ArticleId IdType=\"doi\">[[:space:]]*",
        gsub(
          pattern = "([][{}()+*^$|\\\\?.])",
          replacement = "\\\\\\1",
          x = doi
        ),
        "[[:space:]]*</ArticleId>"
      ),
      x = xml,
      ignore.case = TRUE
    )
    if (found) {
      list(pmid = pmid, xml = xml)
    } else {
      NULL
    }
  }
}
