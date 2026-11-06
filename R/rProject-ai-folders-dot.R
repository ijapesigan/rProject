.AIFolders <- function(path,
                       type) {
  # the folder map of AGENTS.md: the standard folders of the project's
  # template type (inst/template/folders.tsv)
  folders <- .TemplateFolders(
    type = .TemplateTypeGuess(path = path, type = type)
  )
  paste0(
    "| `",
    folders$folder,
    "` | ",
    folders$purpose,
    ifelse(test = folders$private, yes = " (private)", no = ""),
    " |",
    collapse = "\n"
  )
}
