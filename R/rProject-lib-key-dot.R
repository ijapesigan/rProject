.LibKey <- function(families,
                    year) {
  # Family-Family-Family[-etal]-Year: accents dropped, spaces, hyphens, and
  # apostrophes joined (Muth{\'e}n -> Muthen, Le Bourdonnec -> LeBourdonnec)
  fold <- function(x) {
    x <- .LibLatex(x = x, escape = FALSE)
    x <- gsub(pattern = "\\{\\\\(ss)\\}", replacement = "ss", x = x)
    x <- gsub(pattern = "\\{\\\\(ae|AE|oe|OE)\\}", replacement = "\\1", x = x)
    x <- gsub(pattern = "\\{\\\\(o|O|l|L|i)\\}", replacement = "\\1", x = x)
    x <- gsub(pattern = "\\{\\\\dj\\}", replacement = "d", x = x)
    x <- gsub(
      pattern = "\\{\\\\[^A-Za-z{}][[:space:]]*([A-Za-z])\\}",
      replacement = "\\1",
      x = x
    )
    x <- gsub(
      pattern = "\\{\\\\[A-Za-z][[:space:]]+([A-Za-z])\\}",
      replacement = "\\1",
      x = x
    )
    gsub(pattern = "[^A-Za-z]", replacement = "", x = x)
  }
  names <- fold(x = families)
  names <- names[nzchar(names)]
  if (length(names) > 3L) {
    names <- c(names[1:3], "etal")
  }
  paste(c(names, year), collapse = "-")
}
