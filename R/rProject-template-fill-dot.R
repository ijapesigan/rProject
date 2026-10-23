.TemplateFill <- function(text,
                          values) {
  # replaces only the given {{key}} names; anything else in braces (for
  # example {{version}} in docker/metadata-action) is left as it is
  # a value may span several lines; a line that holds only a placeholder
  # whose value is "" is dropped
  empty <- names(values)[vapply(
    X = values,
    FUN = function(x) {
      identical(x, "")
    },
    FUN.VALUE = logical(1)
  )]
  text <- text[!(text %in% paste0("{{", empty, "}}"))]
  for (key in names(values)) {
    text <- gsub(
      pattern = paste0("{{", key, "}}"),
      replacement = values[[key]],
      x = text,
      fixed = TRUE
    )
  }
  # one element per line
  unlist(
    lapply(
      X = text,
      FUN = function(x) {
        if (grepl(pattern = "\n", x = x, fixed = TRUE)) {
          strsplit(x = x, split = "\n", fixed = TRUE)[[1]]
        } else {
          x
        }
      }
    )
  )
}
