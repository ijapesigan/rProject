.DataManifestUsedBy <- function(path,
                                files) {
  scripts <- c(
    list.files(
      path = file.path(path, "R"),
      pattern = "\\.R$",
      full.names = TRUE
    ),
    list.files(
      path = file.path(path, ".setup"),
      pattern = "\\.(R|Rmd|Rtex|sh)$",
      full.names = TRUE,
      recursive = TRUE
    ),
    list.files(
      path = file.path(path, ".sim"),
      pattern = "\\.(R|sh)$",
      full.names = TRUE,
      recursive = TRUE
    )
  )
  scripts <- scripts[
    !grepl(pattern = "/\\.setup/(data-|ai/|logs/)", x = scripts)
  ]
  text <- vapply(
    X = scripts,
    FUN = function(script) {
      paste(readLines(con = script, warn = FALSE), collapse = "\n")
    },
    FUN.VALUE = character(1)
  )
  # relative paths by prefix, not by a regex built from the path
  root <- paste0(
    normalizePath(path = path, winslash = "/"),
    "/"
  )
  vapply(
    X = files,
    FUN = function(file) {
      # the plain name, as scripts refer to it
      name <- sub(pattern = "\\.(xz|gz)$", replacement = "", x = basename(file))
      hits <- normalizePath(
        path = scripts[grepl(pattern = name, x = text, fixed = TRUE)],
        winslash = "/"
      )
      inside <- startsWith(x = hits, prefix = root)
      hits[inside] <- substring(text = hits[inside], first = nchar(root) + 1L)
      paste(hits, collapse = ", ")
    },
    FUN.VALUE = character(1),
    USE.NAMES = FALSE
  )
}
