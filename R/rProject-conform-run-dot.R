.ConformRun <- function(path,
                        reference,
                        remote) {
  # every check, then the rows the reference also has are dropped (a check
  # that fails on the reference too is not a rule)
  template <- .ConformTemplate(path = path)
  required <- .ConformRequired(
    path = path,
    template = template,
    reference = reference
  )
  rows <- .ConformBind(
    rows = list(
      .ConformManifest(path = path, template = template),
      .ConformFolders(path = path),
      .ConformTop(path = path, template = template),
      required,
      .ConformReference(
        path = path,
        reference = reference,
        skip = c(template$files$path, unique(x = required$file))
      ),
      .ConformNames(path = path),
      .ConformCode(path = path),
      .ConformLintError(path = path),
      .ConformLock(path = path),
      .ConformUpload(path = path, template = template),
      .ConformRepo(path = path, remote = remote)
    )
  )
  if (!is.null(x = reference)) {
    key <- function(x, root) {
      pkg <- .LintPkg(path = root)
      gsub(
        pattern = pkg,
        replacement = "{pkg}",
        x = paste(x$rule, x$file, x$message, sep = "|"),
        fixed = TRUE
      )
    }
    base <- .ConformRun(path = reference, reference = NULL, remote = FALSE)
    rows <- rows[
      !(key(x = rows, root = path) %in% key(x = base, root = reference)),
    ]
    rownames(x = rows) <- NULL
  }
  attr(x = rows, which = "type") <- template$type
  rows
}
