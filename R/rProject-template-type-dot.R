.TemplateType <- function(path) {
  type <- .TemplateSettings(path = path)$type
  if (!is.null(x = type)) {
    type <- type[1]
  }
  if (!is.null(x = type) && !(type %in% names(x = .TemplateSets()))) {
    stop(
      paste0(
        "\n\nUnknown type \"",
        type,
        "\" in .setup/scripts/project.R.\nUse one of: ",
        paste(names(x = .TemplateSets()), collapse = ", "),
        ".\n\n"
      ),
      call. = FALSE
    )
  }
  type
}
