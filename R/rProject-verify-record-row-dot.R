.VerifyRecordRow <- function(header,
                             sha,
                             date,
                             result) {
  # one row for a Pushes table, in the order of the table's header
  # (Commit, Date, Result; any other column stays empty)
  cells <- trimws(
    x = strsplit(
      x = gsub(pattern = "^\\||\\|$", replacement = "", x = header),
      split = "|", fixed = TRUE
    )[[1]]
  )
  values <- vapply(
    X = tolower(x = cells),
    FUN = function(cell) {
      switch(
        EXPR = cell,
        commit = sha,
        date = date,
        result = result,
        ""
      )
    },
    FUN.VALUE = character(length = 1),
    USE.NAMES = FALSE
  )
  if (length(x = values) == 0L) {
    values <- c(sha, date, result)
  }
  paste0("| ", paste(values, collapse = " | "), " |")
}
