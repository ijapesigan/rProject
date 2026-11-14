.ConformHouseRow <- function(file,
                             line,
                             rule,
                             message,
                             level) {
  .ConformRow(
    rule = "lint",
    class = "decide",
    file = ifelse(
      test = line == "NA",
      yes = file,
      no = paste0(file, ":", line)
    ),
    message = paste0(level, ": [", rule, "] ", message)
  )
}
