.LinkedStatus <- function(path,
                          functions,
                          sources = NULL) {
  # .setup/r-dependencies/<lib>/<file> is <lib>/<file> in functions, or
  # <file> in sources[["<lib>"]] (the library's pushed R/) when given
  root <- file.path(path, ".setup", "r-dependencies")
  files <- list.files(
    path = root,
    pattern = "\\.R$",
    all.files = TRUE,
    recursive = TRUE
  )
  status <- vapply(
    X = files,
    FUN = function(file) {
      lib <- strsplit(x = file, split = "/", fixed = TRUE)[[1]][1]
      # the copy and its source, as a folder and a relative name
      here <- root
      name <- file
      source <- functions
      if (lib %in% names(x = sources)) {
        here <- file.path(root, lib)
        name <- substring(text = file, first = nchar(x = lib) + 2L)
        source <- sources[[lib]]
      }
      compared <- .VerifyCompare(
        path = here,
        private = source,
        file = name
      )
      variant <- ifelse(
        test = grepl(pattern = "-dot\\.R$", x = name),
        yes = sub(pattern = "-dot\\.R$", replacement = ".R", x = name),
        no = sub(pattern = "\\.R$", replacement = "-dot.R", x = name)
      )
      if (compared == "match") {
        "same"
      } else if (compared == "different") {
        "differs"
      } else if (file.exists(file.path(source, variant))) {
        "name differs"
      } else {
        "no source"
      }
    },
    FUN.VALUE = character(length = 1)
  )
  data.frame(
    file = files,
    status = unname(obj = status),
    stringsAsFactors = FALSE
  )
}
