.LintRow <- function(file,
                     line,
                     rule,
                     message,
                     level = "warning") {
  # one row per finding; the same columns for every check
  n <- length(x = file)
  data.frame(
    file = as.character(x = file),
    line = as.integer(x = line),
    rule = rep_len(x = rule, length.out = n),
    message = rep_len(x = message, length.out = n),
    level = rep_len(x = level, length.out = n),
    stringsAsFactors = FALSE
  )
}
