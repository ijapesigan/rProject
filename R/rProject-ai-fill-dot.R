.AIFill <- function(text,
                    values) {
  text <- paste(text, collapse = "\n")
  for (key in names(values)) {
    text <- gsub(
      pattern = paste0("{{", key, "}}"),
      replacement = values[[key]],
      x = text,
      fixed = TRUE
    )
  }
  strsplit(x = text, split = "\n", fixed = TRUE)[[1]]
}
