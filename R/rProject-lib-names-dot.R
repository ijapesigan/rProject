.LibNames <- function(x) {
  # split a name list on " and " outside braces
  chars <- strsplit(x = x, split = "")[[1]]
  depth <- cumsum(x = (chars == "{") - (chars == "}"))
  # depth before each character
  depth <- c(0L, depth[-length(x = depth)])
  text <- paste(
    ifelse(test = depth == 0L, yes = chars, no = "\001"),
    collapse = ""
  )
  cut <- gregexpr(pattern = "[[:space:]]+and[[:space:]]+", text = text)[[1]]
  if (cut[1] < 0L) {
    trimws(x = x)
  } else {
    starts <- c(1L, cut + attr(x = cut, which = "match.length"))
    ends <- c(cut - 1L, nchar(x = x))
    trimws(x = substring(text = x, first = starts, last = ends))
  }
}
