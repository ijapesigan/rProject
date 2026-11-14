.ConformTemplate <- function(path) {
  # the template of the project: its type, the root of inst/template that
  # applies (rProject's own copy for rProject itself), and the manifest rows
  settings <- .TemplateSettings(path = path)
  type <- tryCatch(
    expr = .TemplateTypeGuess(path = path),
    error = function(e) {
      "cran"
    }
  )
  own <- file.path(path, "inst", "template")
  root <- system.file(
    "template",
    package = "rProject",
    mustWork = TRUE
  )
  if (identical(x = type, y = "rProject") && dir.exists(paths = own)) {
    root <- own
  }
  files <- tryCatch(
    expr = .TemplateFiles(type = type, root = root, settings = settings),
    error = function(e) {
      # an unknown workflow in project.R: the manifest without workflows
      settings$workflows <- NULL
      .TemplateFiles(type = type, root = root, settings = settings)
    }
  )
  list(type = type, root = root, files = files)
}
