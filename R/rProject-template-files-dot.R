.TemplateFiles <- function(type,
                           root = system.file(
                             "template",
                             package = "rProject",
                             mustWork = TRUE
                           ),
                           settings = list()) {
  manifest <- utils::read.delim(
    file = file.path(root, "manifest.tsv"),
    colClasses = "character"
  )
  manifest <- manifest[manifest$set %in% .TemplateSets()[[type]], ]
  # a path component ".x" is stored as "dot-x"
  # (hidden files in inst/ give an R CMD check note)
  manifest$source <- file.path(
    root,
    manifest$set,
    vapply(
      X = strsplit(x = manifest$path, split = "/", fixed = TRUE),
      FUN = function(x) {
        paste(
          sub(pattern = "^\\.", replacement = "dot-", x = x),
          collapse = "/"
        )
      },
      FUN.VALUE = character(1)
    )
  )
  manifest$kind <- rep(x = "file", times = nrow(manifest))
  manifest$fill <- rep(x = FALSE, times = nrow(manifest))
  # workflows the project chooses (workflows in project.R),
  # from the catalog in inst/template/workflows/
  workflows <- settings$workflows
  if (length(workflows) > 0L) {
    catalog <- sub(
      pattern = "\\.yml$",
      replacement = "",
      x = list.files(
        path = file.path(root, "workflows"),
        pattern = "\\.yml$"
      )
    )
    unknown <- setdiff(workflows, catalog)
    if (length(unknown) > 0L) {
      stop(
        paste0(
          "\n\nUnknown workflows in .setup/scripts/project.R: ",
          paste(unknown, collapse = ", "),
          "\nUse any of:\n",
          paste(catalog, collapse = "\n"),
          "\n\n"
        ),
        call. = FALSE
      )
    }
    source <- file.path(root, "workflows", paste0(workflows, ".yml"))
    # a workflow with {{title}} is the project's own daily build:
    # named <workflow>-<workflow_daily>.yml (or <workflow>.yml)
    daily <- .TemplateHas(files = source, keys = "title")
    suffix <- settings$workflow_daily
    name <- workflows
    if (any(daily) && length(suffix) > 0L && nzchar(suffix[1])) {
      name[daily] <- paste0(workflows[daily], "-", suffix[1])
    }
    manifest <- rbind(
      manifest,
      data.frame(
        set = "workflows",
        tier = "2",
        path = file.path(".github", "workflows", paste0(name, ".yml")),
        source = source,
        kind = "file",
        fill = FALSE
      )
    )
  }
  # the folder skeleton of the type: an empty .gitignore in each folder
  # marked create in inst/template/folders.tsv
  folders <- .TemplateFolders(type = type, root = root)
  folders <- folders[folders$create, ]
  dirs <- paste0(folders$folder, ".gitignore")
  dirs <- dirs[!(dirs %in% manifest$path)]
  if (length(dirs) > 0L) {
    manifest <- rbind(
      manifest,
      data.frame(
        set = "folders",
        tier = "2",
        path = dirs,
        source = NA_character_,
        kind = "dir",
        fill = FALSE
      )
    )
  }
  # tier 2 files with a placeholder ({{project}}, {{public}}, ...) are
  # filled when written; a file with {{title}} is the daily workflow
  text <- manifest$kind == "file" & manifest$tier == "2"
  manifest$fill[text] <- .TemplateHas(
    files = manifest$source[text],
    keys = names(.TemplateKeys())
  )
  manifest$daily <- FALSE
  manifest$daily[text] <- .TemplateHas(
    files = manifest$source[text],
    keys = "title"
  )
  rownames(manifest) <- NULL
  manifest
}
