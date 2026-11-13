.LibXmlDecode <- function(x) {
  # &lt; &gt; &quot; &apos; and numeric entities; &amp; last
  numeric <- unique(
    x = unlist(
      x = regmatches(
        x = x,
        m = gregexpr(pattern = "&#[xX]?[0-9A-Fa-f]+;", text = x)
      )
    )
  )
  for (entity in numeric) {
    digits <- sub(
      pattern = "^&#([xX]?[0-9A-Fa-f]+);$",
      replacement = "\\1",
      x = entity
    )
    code <- ifelse(
      test = grepl(pattern = "^[xX]", x = digits),
      yes = strtoi(x = substring(text = digits, first = 2), base = 16L),
      no = strtoi(x = digits, base = 10L)
    )
    x <- gsub(
      pattern = entity,
      replacement = intToUtf8(x = code),
      x = x,
      fixed = TRUE
    )
  }
  x <- gsub(pattern = "&lt;", replacement = "<", x = x, fixed = TRUE)
  x <- gsub(pattern = "&gt;", replacement = ">", x = x, fixed = TRUE)
  x <- gsub(pattern = "&quot;", replacement = "\"", x = x, fixed = TRUE)
  x <- gsub(pattern = "&apos;", replacement = "'", x = x, fixed = TRUE)
  gsub(pattern = "&amp;", replacement = "&", x = x, fixed = TRUE)
}
