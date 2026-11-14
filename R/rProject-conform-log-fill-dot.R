.ConformLogFill <- function(log_file,
                            changes,
                            listed) {
  # replaces the TODO placeholders that Log() leaves when no spec or no
  # clone is found: the spec line, the commit message bullets, the lists of
  # new files (the upload folder's), and the make commands
  lines <- readLines(con = log_file, warn = FALSE)
  new <- listed[!.ConformLinked(file = listed)]
  none <- length(x = unlist(x = changes[c("new", "overleaf", "local")])) == 0L
  bullets <- c(
    if (length(x = changes$new) > 0L) {
      paste("- Add", changes$new)
    },
    if (length(x = changes$overleaf) > 0L) {
      paste("- Remove", changes$overleaf)
    },
    if (none) {
      "- Structure audit (Conform)"
    }
  )
  commands <- c(
    "- `Conform()` (the structure audit; rProject `2026-11-13-conform` spec)",
    "- `ConformFix()` (writes the files listed above; never overwrites)"
  )
  lines[lines == "Spec: TODO"] <- paste(
    "Spec: rProject `.setup/ai/specs/2026-11-13-conform.md`",
    "(Conform and ConformFix)"
  )
  section <- ""
  fence <- FALSE
  out <- character(length = 0)
  for (line in lines) {
    if (grepl(pattern = "^#+ ", x = line)) {
      section <- line
    }
    if (startsWith(x = line, prefix = "```")) {
      fence <- !fence
    }
    if (identical(x = line, y = "- TODO")) {
      if (fence) {
        out <- c(out, bullets)
      } else if (grepl(pattern = "Make commands", x = section)) {
        out <- c(out, commands)
      } else if (grepl(pattern = "New$", x = section)) {
        listing <- "- (none)"
        if (length(x = new) > 0L) {
          listing <- paste("-", new)
        }
        out <- c(out, listing)
      } else if (grepl(pattern = "Edited$", x = section)) {
        out <- c(out, "- (none)")
      } else if (grepl(pattern = "^### Delete", x = section)) {
        out <- c(out, "- (none)")
      } else {
        out <- c(out, line)
      }
    } else {
      out <- c(out, line)
    }
  }
  writeLines(text = out, con = log_file)
  invisible(x = NULL)
}
