.TemplateFiles <- function(type,
                           root = system.file(
                             "template",
                             package = "rProject",
                             mustWork = TRUE
                           )) {
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
  rownames(manifest) <- NULL
  manifest
}
