.TemplateFolders <- function(type = NULL,
                             root = system.file(
                               "template",
                               package = "rProject",
                               mustWork = TRUE
                             )) {
  # the standard folders (inst/template/folders.tsv)
  folders <- utils::read.delim(
    file = file.path(root, "folders.tsv"),
    colClasses = "character",
    quote = ""
  )
  folders$private <- as.logical(folders$private)
  folders$create <- as.logical(folders$create)
  if (!is.null(type)) {
    keep <- vapply(
      X = strsplit(x = folders$types, split = ",", fixed = TRUE),
      FUN = function(x) {
        "all" %in% x || type %in% x
      },
      FUN.VALUE = logical(1)
    )
    folders <- folders[keep, ]
  }
  rownames(folders) <- NULL
  folders
}
