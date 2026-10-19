.VerifyLogFiles <- function(log_file,
                            project,
                            subject = NULL) {
  lines <- readLines(
    con = log_file,
    warn = FALSE
  )
  heading <- regexpr(pattern = "^#+", text = lines)
  level <- ifelse(heading > 0, attr(heading, "match.length"), 0L)
  title <- trimws(sub(pattern = "^#+", replacement = "", x = lines))
  starts <- which(
    level > 0 & grepl(pattern = "Files to update in Overleaf", x = title)
  )
  if (!is.null(subject)) {
    scope <- .VerifyLogScope(
      lines = lines,
      level = level,
      title = title,
      subject = subject
    )
    if (!is.null(scope)) {
      starts <- scope
    }
  }
  file <- character(0)
  action <- character(0)
  for (start in starts) {
    # a suffix such as ": dotfiles" names the project the section is for
    suffix <- sub(
      pattern = "^.*Files to update in Overleaf:?",
      replacement = "",
      x = title[start]
    )
    suffix <- trimws(sub(pattern = "\\(.*\\)", replacement = "", x = suffix))
    keep <- !nzchar(suffix) ||
      grepl(pattern = tolower(suffix), x = tolower(project), fixed = TRUE)
    after <- which(level > 0 & level <= level[start])
    end <- c(after[after > start], length(lines) + 1L)[1] - 1L
    current <- "upload"
    if (keep && end > start) {
      for (i in seq(from = start + 1L, to = end)) {
        if (level[i] > 0) {
          current <- ifelse(
            grepl(pattern = "Delete", x = title[i]),
            "delete",
            ifelse(
              grepl(
                pattern = "Generated|do not upload",
                x = title[i],
                ignore.case = TRUE
              ),
              "skip",
              "upload"
            )
          )
        } else if (grepl(pattern = "^- ", x = lines[i])) {
          item <- strsplit(
            x = sub(pattern = "^- ", replacement = "", x = lines[i]),
            split = " "
          )[[1]][1]
          item <- gsub(pattern = "`|:$|,$|/$", replacement = "", x = item)
          if (
            current != "skip" &&
              grepl(pattern = "^[A-Za-z0-9._][A-Za-z0-9._/-]*$", x = item)
          ) {
            file <- c(file, item)
            action <- c(action, current)
          }
        }
      }
    }
  }
  unique(
    data.frame(
      file = file,
      action = action,
      stringsAsFactors = FALSE
    )
  )
}
