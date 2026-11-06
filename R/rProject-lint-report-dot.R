.LintReport <- function(rows,
                        max_rows = 200L) {
  # one table; a long one prints its counts first, then the first rows
  if (nrow(x = rows) == 0L) {
    cat("House checks: nothing to report.\n")
  } else {
    counts <- as.data.frame(
      x = table(rule = rows$rule, level = rows$level),
      stringsAsFactors = FALSE
    )
    counts <- counts[counts$Freq > 0L, , drop = FALSE]
    cat("House checks:\n")
    print(x = counts, row.names = FALSE, right = FALSE)
    cat("\n")
    shown <- rows[seq_len(length.out = min(nrow(x = rows), max_rows)), ]
    print(x = shown, row.names = FALSE, right = FALSE)
    if (nrow(x = rows) > max_rows) {
      cat("... and", nrow(x = rows) - max_rows, "more rows.\n")
    }
  }
  invisible(x = rows)
}
