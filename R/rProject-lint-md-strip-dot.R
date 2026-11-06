.LintMdStrip <- function(lines) {
  # blank fenced code, inline code, and the YAML header; line numbers hold
  inside <- FALSE
  for (i in seq_along(along.with = lines)) {
    fence <- grepl(pattern = "^\\s*```", x = lines[i])
    if (inside || fence) {
      lines[i] <- ""
    }
    if (fence) {
      inside <- !inside
    }
  }
  if (length(x = lines) > 0L && lines[1] == "---") {
    end <- which(x = lines == "---")
    if (length(x = end) > 1L) {
      lines[seq_len(length.out = end[2])] <- ""
    }
  }
  gsub(pattern = "`[^`]*`", replacement = "", x = lines)
}
