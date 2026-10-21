.TemplateType <- function(path) {
  project_r <- file.path(path, ".setup", "scripts", "project.R")
  type <- NULL
  if (file.exists(project_r)) {
    lines <- readLines(
      con = project_r,
      warn = FALSE
    )
    hit <- regmatches(
      x = lines,
      m = regexpr(pattern = "^type <- \"[^\"]+\"", text = lines)
    )
    if (length(hit) > 0L) {
      type <- sub(
        pattern = "^type <- \"([^\"]+)\"",
        replacement = "\\1",
        x = hit[1]
      )
    }
  }
  if (!is.null(type) && !(type %in% names(.TemplateSets()))) {
    stop(
      paste0(
        "\n\nUnknown type \"",
        type,
        "\" in .setup/scripts/project.R.\nUse one of: ",
        paste(names(.TemplateSets()), collapse = ", "),
        ".\n\n"
      ),
      call. = FALSE
    )
  }
  type
}
