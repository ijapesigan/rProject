.AIRows <- function(type,
                    rows) {
  rows <- unlist(
    x = rows[intersect(x = names(x = rows), y = type)],
    use.names = FALSE
  )
  ifelse(
    test = length(x = rows) > 0L,
    yes = paste(rows, collapse = "\n"),
    no = ""
  )
}
