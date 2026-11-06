.LibParse <- function(text) {
  # one biblatex entry from house-style text: type, key, and fields
  # (values without their outer braces); ok = FALSE when it does not parse
  text <- paste(text, collapse = "\n")
  starts <- gregexpr(pattern = "@[A-Za-z]+[[:space:]]*\\{", text = text)[[1]]
  n <- sum(starts > 0)
  out <- list(
    type = NA_character_,
    key = NA_character_,
    fields = character(length = 0),
    n = n,
    ok = FALSE,
    error = "no entry"
  )
  if (n > 0) {
    chars <- strsplit(x = text, split = "")[[1]]
    i <- starts[1] + 1L
    head <- regmatches(
      x = text,
      m = regexpr(
        pattern = paste0(
          "@[A-Za-z]+[[:space:]]*\\{",
          "[[:space:]]*[^,[:space:]]+[[:space:]]*,"
        ),
        text = text
      )
    )
    out$type <- sub(pattern = "^@([A-Za-z]+).*$", replacement = "\\1", x = head)
    out$key <- trimws(
      x = sub(
        pattern = "^@[A-Za-z]+[[:space:]]*\\{([^,]+),$",
        replacement = "\\1",
        x = head
      )
    )
    i <- starts[1] + nchar(x = head)
    fields <- character(length = 0)
    error <- ""
    closed <- FALSE
    while (i <= length(x = chars) && !closed && !nzchar(x = error)) {
      ch <- chars[i]
      if (grepl(pattern = "[[:space:],]", x = ch)) {
        i <- i + 1L
      } else if (ch == "}") {
        closed <- TRUE
      } else if (grepl(pattern = "[A-Za-z]", x = ch)) {
        j <- i
        while (
          j <= length(
            x = chars
          ) && grepl(pattern = "[A-Za-z0-9_+-]", x = chars[j])
        ) {
          j <- j + 1L
        }
        name <- tolower(x = paste(chars[i:(j - 1L)], collapse = ""))
        while (
          j <= length(x = chars) && grepl(pattern = "[[:space:]]", x = chars[j])
        ) {
          j <- j + 1L
        }
        if (j > length(x = chars) || chars[j] != "=") {
          error <- paste0("no '=' after field ", name)
        } else {
          j <- j + 1L
          while (
            j <= length(
              x = chars
            ) && grepl(pattern = "[[:space:]]", x = chars[j])
          ) {
            j <- j + 1L
          }
          if (j <= length(x = chars) && chars[j] == "{") {
            depth <- 1L
            k <- j + 1L
            while (k <= length(x = chars) && depth > 0L) {
              if (chars[k] == "{" && chars[k - 1L] != "\\") {
                depth <- depth + 1L
              } else if (chars[k] == "}" && chars[k - 1L] != "\\") {
                depth <- depth - 1L
              }
              k <- k + 1L
            }
            if (depth > 0L) {
              error <- paste0("unbalanced braces in field ", name)
            } else {
              value <- paste(chars[(j + 1L):(k - 2L)], collapse = "")
              if (k - 2L < j + 1L) {
                value <- ""
              }
              if (name %in% names(x = fields)) {
                error <- paste0("duplicate field ", name)
              }
              fields[name] <- value
              i <- k
            }
          } else {
            # a bare value (a number or a macro)
            k <- j
            while (
              k <= length(x = chars) &&
                !grepl(pattern = "[,}[:space:]]", x = chars[k])
            ) {
              k <- k + 1L
            }
            fields[name] <- paste(chars[j:(k - 1L)], collapse = "")
            i <- k
          }
        }
      } else {
        error <- paste0("unexpected character '", ch, "'")
      }
    }
    if (!closed && !nzchar(x = error)) {
      error <- "the entry is not closed"
    }
    out$fields <- fields
    out$ok <- !nzchar(x = error)
    out$error <- error
  }
  out
}
