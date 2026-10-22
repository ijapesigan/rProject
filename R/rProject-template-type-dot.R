.TemplateType <- function(path) {
  type <- .TemplateSettings(path = path)$type
  if (!is.null(type)) {
    type <- type[1]
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
