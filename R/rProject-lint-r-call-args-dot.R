.LintRCallArgs <- function(data,
                           children) {
  # split a call's children at its commas: for each argument, its name
  # (or NA), and the line and column of its first token
  children <- children[data$token[children] != "COMMENT"]
  segments <- list()
  current <- integer(length = 0L)
  for (child in children) {
    if (data$token[child] %in% c("','", "')'")) {
      segments[[length(x = segments) + 1L]] <- current
      current <- integer(length = 0L)
    } else {
      current <- c(current, child)
    }
  }
  segments <- segments[lengths(x = segments) > 0L]
  lapply(
    X = segments,
    FUN = function(segment) {
      named <- "EQ_SUB" %in% data$token[segment]
      list(
        name = ifelse(
          test = named,
          yes = gsub(
            pattern = "[`\"']",
            replacement = "",
            x = data$text[segment[1]]
          ),
          no = NA_character_
        ),
        line = data$line1[segment[1]],
        col = data$col1[segment[1]]
      )
    }
  )
}
