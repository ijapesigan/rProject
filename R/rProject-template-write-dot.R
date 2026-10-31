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
  # placeholder values: the project, its public repository, and the
  # daily docker workflow's settings (project.R)
  info <- .RepoInfo(path = path)
  public <- info$public_github
  values <- .TemplateKeys(settings = settings, public = public)
  # a file that names the public repository is not written without one
  needs_public <- rep(x = FALSE, times = nrow(files))
  needs_public[files$fill] <- .TemplateHas(
    files = files$source[files$fill],
    keys = c("public", "owner", "repo")
  )
  if (!nzchar(values$public) && any(needs_public)) {
    message(
      paste0(
        "\n\nNo public repository (.setup/repo/public-github.md);",
        " not written:\n",
        paste(files$path[needs_public], collapse = "\n"),
        "\n\n"
      )
    )
    files <- files[!needs_public, ]
  }
  if (any(files$daily)) {
    following <- settings$workflow_next
    following <- following[nzchar(following)]
    problems <- character(0)
    if (!nzchar(values$title)) {
      problems <- "workflow_title is missing"
    }
    valid <- grepl(pattern = "^[^/ ]+/[^/ ]+$", x = following)
    if (any(!valid)) {
      problems <- c(
        problems,
        paste0(
          "workflow_next \"",
          following[!valid],
          "\" is not owner/repository"
        )
      )
    }
    if (length(problems) > 0L) {
      stop(
        paste0(
          "\n\n",
          paste(files$path[files$daily], collapse = ", "),
          ": ",
          paste(problems, collapse = "; "),
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
        values = values
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
  # every template file is written (the template wins); the ones kept in
  # Overleaf as regular files are named for upload
  write <- differs
  kept <- write & .TemplateKept(files = files)
  edited <- write & exists & !kept
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
  if (any(kept)) {
    message(
      paste0(
        "\n\nTo upload to Overleaf (kept there as regular files; if one",
        " is still a link, delete the link first):\n",
        paste(files$path[kept], collapse = "\n"),
        "\n\n"
      )
    )
  }
  if (!any(write) && length(removed) == 0L) {
    message("\n\nTemplate files are up to date.\n\n")
  }
  written <- files$path[write]
  attr(written, "removed") <- removed
  written
}
