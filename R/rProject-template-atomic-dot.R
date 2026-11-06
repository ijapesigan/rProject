.TemplateAtomic <- function(target,
                            text = NULL,
                            from = NULL) {
  # write through a temporary file and a rename, so a process reading the
  # target keeps the old file. make-project.R runs while Template() replaces
  # it: written in place, R reads on into the new file from the old file's
  # size, and parses whatever is there.
  temp <- tempfile(
    pattern = paste0(".", basename(path = target), "-"),
    tmpdir = dirname(path = target)
  )
  on.exit(expr = unlink(x = temp), add = TRUE)
  if (is.null(x = from)) {
    writeLines(text = text, con = temp)
  } else {
    file.copy(from = from, to = temp, overwrite = TRUE)
  }
  if (file.exists(target)) {
    Sys.chmod(paths = temp, mode = file.mode(target), use_umask = FALSE)
  }
  file.rename(from = temp, to = target)
}
