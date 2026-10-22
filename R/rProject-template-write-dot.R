.TemplateWrite <- function(path,
                           type,
                           check) {
  settings <- .TemplateSettings(path = path)
  if (identical(type, "rProject")) {
    if (!check) {
      .TemplateSources(path = path)
    }
    root <- file.path(path, "inst", "template")
  } else {
    root <- system.file(
      "template",
      package = "rProject",
      mustWork = TRUE
    )
  }
  files <- .TemplateFiles(
    type = type,
    root = root,
    settings = settings
  )
  # the project's daily workflow: title and cron from project.R
  values <- list(
    title = settings$workflow_title,
    cron = settings$workflow_cron
  )
  if (any(files$fill)) {
    missing <- names(values)[lengths(values) == 0L]
    if (length(missing) > 0L) {
      stop(
        paste0(
          "\n\n",
          paste(files$path[files$fill], collapse = ", "),
          " needs ",
          paste0("workflow_", missing, collapse = " and "),
          " in .setup/scripts/project.R.\n\n"
        ),
        call. = FALSE
      )
    }
  }
  content <- function(i) {
    if (files$kind[i] == "dir") {
      character(0)
    } else {
      .TemplateFill(
        text = readLines(con = files$source[i], warn = FALSE),
        values = lapply(X = values, FUN = `[`, 1L)
      )
    }
  }
  target <- file.path(path, files$path)
  exists <- file.exists(target)
  differs <- !exists
  # an existing folder's .gitignore is the user's: never compared
  plain <- exists & files$kind == "file" & !files$fill
  differs[plain] <- tools::md5sum(target[plain]) !=
    tools::md5sum(files$source[plain])
  for (i in which(exists & files$fill)) {
    differs[i] <- !identical(
      readLines(con = target[i], warn = FALSE),
      content(i)
    )
  }
  tier2 <- files$tier == "2"
  write <- tier2 & differs
  edited <- write & exists
  refresh <- !tier2 & differs
  removed <- .TemplateRemove(
    path = path,
    root = root,
    check = check
  )
  if (!check) {
    for (i in which(write)) {
      dir.create(
        path = dirname(target[i]),
        showWarnings = FALSE,
        recursive = TRUE
      )
      if (files$kind[i] == "file" && !files$fill[i]) {
        file.copy(
          from = files$source[i],
          to = target[i],
          overwrite = TRUE
        )
      } else {
        writeLines(text = content(i), con = target[i])
      }
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
  if (!any(write) && !any(refresh) && length(removed) == 0L) {
    message("\n\nTemplate files are up to date.\n\n")
  }
  written <- files$path[write]
  attr(written, "removed") <- removed
  written
}
