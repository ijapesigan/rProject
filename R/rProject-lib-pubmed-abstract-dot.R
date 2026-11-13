.LibPubMedAbstract <- function(xml) {
  # the abstract of a PubMed XML record as lib-* text (LaTeX, ASCII), or
  # NA_character_ when the record has none
  parts <- regmatches(
    x = xml,
    m = gregexpr(
      pattern = "(?s)<AbstractText[^>]*>.*?</AbstractText>",
      text = xml,
      perl = TRUE
    )
  )[[1]]
  if (length(x = parts) == 0L) {
    NA_character_
  } else {
    parts <- vapply(
      X = parts,
      FUN = function(part) {
        label <- sub(
          pattern = "(?s)^<AbstractText[^>]*?[[:space:]]Label=\"([^\"]*)\".*$",
          replacement = "\\1",
          x = part,
          perl = TRUE
        )
        label <- ifelse(
          test = identical(x = label, y = part),
          yes = "",
          no = label
        )
        body <- sub(
          pattern = "(?s)^<AbstractText[^>]*>(.*)</AbstractText>$",
          replacement = "\\1",
          x = part,
          perl = TRUE
        )
        body <- trimws(
          x = gsub(pattern = "<[^>]+>", replacement = "", x = body)
        )
        if (!nzchar(x = label) || toupper(x = label) %in% c(
          "UNLABELLED", "UNLABELED", "NLM_CATEGORY"
        )) {
          body
        } else {
          label <- paste0(
            toupper(x = substr(x = label, start = 1, stop = 1)),
            tolower(x = substr(x = label, start = 2, stop = nchar(x = label)))
          )
          paste0(label, ": ", body)
        }
      },
      FUN.VALUE = character(length = 1),
      USE.NAMES = FALSE
    )
    text <- paste(parts[nzchar(x = parts)], collapse = " ")
    text <- .LibXmlDecode(x = text)
    text <- gsub(pattern = "[[:space:]]+", replacement = " ", x = text)
    text <- trimws(
      x = gsub(
        pattern = "\\(PsycInfo Database Record \\(c\\)[^)]*\\)",
        replacement = "",
        x = text
      )
    )
    # statistics in math mode: p < .001, n = 42
    text <- gsub(
      pattern = "\\b([pn]) ?([<=>]) ?(\\.?[0-9]+(?:\\.[0-9]+)?)",
      replacement = "$\\1 \\2 \\3$",
      x = text,
      perl = TRUE
    )
    # straight double quotes as TeX quotes
    text <- gsub(
      pattern = "(^|[[:space:]([])\"",
      replacement = "\\1``",
      x = text
    )
    text <- gsub(pattern = "\"", replacement = "''", x = text)
    if (nzchar(x = text)) {
      .LibLatex(x = text)
    } else {
      NA_character_
    }
  }
}
