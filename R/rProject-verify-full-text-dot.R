.VerifyFullText <- function(path,
                            private) {
  # warn, never fail: the full text often comes in the next push, and some
  # works have none to get. Only the entries that this commit adds count.
  added <- .VerifyCommitFiles(private = private)
  added <- added$file[added$status == "A"]
  added <- basename(
    path = added[
      grepl(pattern = "^\\.setup/latex/bib/lib-.*\\.bib$", x = added)
    ]
  )
  result <- .LibFullText(path = private, private = private)
  entries <- result$entries[
    result$entries$file %in% added & result$entries$status != "ok", ,
    drop = FALSE
  ]
  warn <- character(length = 0)
  if (nrow(x = entries) > 0L) {
    warn <- paste0(
      entries$key,
      " (",
      entries$status,
      "): upload .setup/notes/pdf/",
      sub(pattern = "\\.bib$", replacement = ".pdf", x = entries$file),
      " (or epub/)"
    )
  }
  if (length(x = result$orphans) > 0L) {
    warn <- c(
      warn,
      paste("no entry for", paste(result$orphans, collapse = ", "))
    )
  }
  if (length(x = warn) > 0L) {
    c(status = "warn", detail = paste(warn, collapse = "; "))
  } else {
    c(
      status = "pass",
      detail = paste(length(x = added), "new entries; none missing")
    )
  }
}
