.AIRows <- function(type,
                    rows) {
  rows <- unlist(rows[intersect(names(rows), type)], use.names = FALSE)
  ifelse(length(rows) > 0L, paste(rows, collapse = "\n"), "")
}
