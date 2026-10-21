.TemplateWrite <- function(path,
                           type,
                           check) {
  if (identical(type, "rProject")) {
    if (!check) {
      .TemplateSources(path = path)
    }
    files <- .TemplateFiles(
      type = type,
      root = file.path(path, "inst", "template")
    )
  } else {
    files <- .TemplateFiles(type = type)
  }
  target <- file.path(path, files$path)
  exists <- file.exists(target)
  differs <- !exists
  differs[exists] <- tools::md5sum(target[exists]) !=
    tools::md5sum(files$source[exists])
  tier2 <- files$tier == "2"
  write <- tier2 & differs
  edited <- write & exists
  refresh <- !tier2 & differs
  if (!check) {
    for (i in which(write)) {
      dir.create(
        path = dirname(target[i]),
        showWarnings = FALSE,
        recursive = TRUE
      )
      file.copy(
        from = files$source[i],
        to = target[i],
        overwrite = TRUE
      )
    }
  }
  if (any(write)) {
    message(
      paste0(
        "\n\n",
        ifelse(
          check,
          "Template files to write:\n",
          "Template files written:\n"
        ),
        paste(files$path[write], collapse = "\n"),
        "\n\n"
      )
    )
  }
  if (any(edited)) {
    message(
      paste0(
        "\n\n",
        ifelse(check, "To overwrite", "Overwritten"),
        " (the template wins; change it in rProject's inst/template/):\n",
        paste(files$path[edited], collapse = "\n"),
        "\n\n"
      )
    )
  }
  if (any(refresh)) {
    message(
      paste0(
        "\n\nLinks to refresh in Overleaf (they differ from rProject):\n",
        paste(files$path[refresh], collapse = "\n"),
        "\n\n"
      )
    )
  }
  if (!any(write) && !any(refresh)) {
    message("\n\nTemplate files are up to date.\n\n")
  }
  files$path[write]
}
