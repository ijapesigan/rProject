.LintRBracesLines <- function(data) {
  # the lines of bodies without braces, for if, else, for, while, repeat,
  # and function; `else if` is fine
  if (is.null(x = data)) {
    integer(length = 0L)
  } else {
    kids <- split(
      x = seq_len(length.out = nrow(x = data)),
      f = factor(x = data$parent, levels = unique(x = data$parent))
    )
    bodies <- c("expr", "expr_or_assign_or_help", "equal_assign", "forcond")
    keys <- c("IF", "ELSE", "FOR", "WHILE", "REPEAT", "FUNCTION", "'\\\\'")
    lines <- integer(length = 0L)
    for (i in which(x = data$token %in% keys)) {
      children <- kids[[as.character(x = data$parent[i])]]
      after <- children[children > i]
      # the token's own condition: the body is the first expr after it,
      # past the parentheses of if, while, and function
      close <- which(x = data$token[after] == "')'")
      if (data$token[i] %in% c(
        "IF",
        "WHILE",
        "FUNCTION",
        "'\\\\'"
      ) && length(x = close) > 0L) {
        after <- after[-seq_len(length.out = close[1])]
      }
      if (data$token[i] == "FOR") {
        after <- after[data$token[after] != "forcond"]
      }
      after <- after[data$token[after] %in% bodies]
      if (length(x = after) > 0L) {
        first <- kids[[as.character(x = data$id[after[1]])]]
        lead <- ifelse(
          test = length(x = first) > 0L,
          yes = data$token[first[1]],
          no = ""
        )
        else_if <- data$token[i] == "ELSE" && lead == "IF"
        if (lead != "'{'" && !else_if) {
          lines <- c(lines, data$line1[i])
        }
      }
    }
    lines
  }
}
