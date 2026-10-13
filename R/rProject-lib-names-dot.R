.LibNames <- function(x) {
  # split a name list on " and " outside braces
  chars <- strsplit(x = x, split = "")[[1]]
  depth <- cumsum((chars == "{") - (chars == "}"))
  # depth before each character
  depth <- c(0L, depth[-length(depth)])
  text <- paste(ifelse(depth == 0L, chars, "\001"), collapse = "")
  cut <- gregexpr(pattern = "[[:space:]]+and[[:space:]]+", text = text)[[1]]
  if (cut[1] < 0L) {
    trimws(x)
  } else {
    starts <- c(1L, cut + attr(cut, "match.length"))
    ends <- c(cut - 1L, nchar(x))
    trimws(substring(text = x, first = starts, last = ends))
  }
}
