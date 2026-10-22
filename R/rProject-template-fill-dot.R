.TemplateFill <- function(text,
                          values) {
  # replaces only the given {{key}} names; anything else in braces (for
  # example {{version}} in docker/metadata-action) is left as it is
  for (key in names(values)) {
    text <- gsub(
      pattern = paste0("{{", key, "}}"),
      replacement = values[[key]],
      x = text,
      fixed = TRUE
    )
  }
  text
}
