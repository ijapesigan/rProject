.TemplateSources <- function(path) {
  # rProject only: the tier 1 files that rProject uses itself are linked
  # from rProject's own copy in Overleaf, so that copy is the source
  # and inst/template holds a copy of it
  root <- file.path(path, "inst", "template")
  files <- .TemplateFiles(type = "rProject", root = root)
  files <- files[files$tier == "1", ]
  live <- file.path(path, files$path)
  changed <- file.exists(live) & (
    !file.exists(files$source) |
      tools::md5sum(live) != tools::md5sum(files$source)
  )
  for (i in which(changed)) {
    dir.create(
      path = dirname(files$source[i]),
      showWarnings = FALSE,
      recursive = TRUE
    )
    file.copy(
      from = live[i],
      to = files$source[i],
      overwrite = TRUE
    )
  }
  invisible(files$source[changed])
}
