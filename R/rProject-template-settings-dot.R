.TemplateSettings <- function(path) {
  # the template settings in project.R: project, type, workflows,
  # workflow_daily, workflow_title, workflow_cron, workflow_next
  # only assignments of character constants (or c() of them) are read;
  # nothing in project.R is run
  names <- c(
    "project",
    "type",
    "workflows",
    "workflow_daily",
    "workflow_title",
    "workflow_cron",
    "workflow_next"
  )
  settings <- list()
  project_r <- file.path(path, ".setup", "scripts", "project.R")
  if (file.exists(project_r)) {
    exprs <- tryCatch(
      expr = parse(file = project_r, keep.source = FALSE),
      error = function(e) {
        expression()
      }
    )
    for (expr in as.list(exprs)) {
      if (
        is.call(expr) &&
          identical(expr[[1]], as.name("<-")) &&
          is.name(expr[[2]]) &&
          as.character(expr[[2]]) %in% names
      ) {
        value <- expr[[3]]
        constant <- is.character(value) || (
          is.call(value) &&
            identical(value[[1]], as.name("c")) &&
            all(
              vapply(
                X = as.list(value)[-1],
                FUN = is.character,
                FUN.VALUE = logical(1)
              )
            )
        )
        if (constant) {
          settings[[as.character(expr[[2]])]] <- as.character(
            eval(expr = value, envir = baseenv())
          )
        }
      }
    }
  }
  settings
}
