.ConformWrite <- function(path,
                          rows,
                          reference,
                          template,
                          remove = FALSE) {
  # applies the `fix` rows; never overwrites a file; removes a stray only
  # with `remove = TRUE`, and never a locked copy; returns the new files,
  # the files to delete in Overleaf, the local-only removals, and the
  # strays that were kept
  fix <- rows[rows$class == "fix", ]
  new <- character(length = 0)
  overleaf <- character(length = 0)
  local <- character(length = 0)
  kept <- character(length = 0)
  locked <- .ConformLocked(path = path)
  pkg <- .LintPkg(path = path)
  for (i in seq_len(length.out = nrow(x = fix))) {
    file <- fix$file[i]
    target <- file.path(path, file)
    how <- fix$fix[i]
    if (how %in% c("template", "reference", "default")) {
      if (!file.exists(target)) {
        dir.create(
          path = dirname(path = target),
          showWarnings = FALSE,
          recursive = TRUE
        )
        if (identical(x = how, y = "template")) {
          source <- template$files$source[template$files$path == file]
          done <- file.copy(from = source[1], to = target, overwrite = FALSE)
        } else {
          text <- if (identical(x = how, y = "reference")) {
            gsub(
              pattern = .LintPkg(path = reference),
              replacement = pkg,
              x = readLines(con = file.path(reference, file), warn = FALSE),
              fixed = TRUE
            )
          } else {
            .ConformDefault(path = path, file = file)
          }
          writeLines(text = text, con = target)
          done <- TRUE
        }
        if (done) {
          new <- c(new, file)
        }
      }
    } else if (identical(x = how, y = "remove-upload")) {
      # a tier 2 file in an unpushed upload folder (never from the project)
      upload <- file.path(.UploadDest(path = path), file)
      if (file.exists(upload)) {
        unlink(x = upload)
      }
    } else if (how %in% c("remove-overleaf", "remove-local") && (
      !remove || sub(pattern = "/$", replacement = "", x = file) %in% locked
    )) {
      kept <- c(kept, file)
    } else if (identical(x = how, y = "remove-overleaf")) {
      if (file.exists(target)) {
        unlink(x = target)
        overleaf <- c(overleaf, file)
      }
    } else if (identical(x = how, y = "remove-local")) {
      if (dir.exists(paths = target)) {
        unlink(x = target, recursive = TRUE)
        local <- c(local, file)
      }
    }
  }
  list(new = new, overleaf = overleaf, local = local, kept = kept)
}
