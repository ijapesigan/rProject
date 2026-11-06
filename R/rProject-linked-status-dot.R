.LinkedStatus <- function(path,
                          functions) {
  # .setup/r-dependencies/<lib>/<file> is <lib>/<file> in functions
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
      compared <- .VerifyCompare(
        path = root,
        private = functions,
        file = file
      )
      variant <- ifelse(
        test = grepl(pattern = "-dot\\.R$", x = file),
        yes = sub(pattern = "-dot\\.R$", replacement = ".R", x = file),
        no = sub(pattern = "\\.R$", replacement = "-dot.R", x = file)
      )
      if (compared == "match") {
        "same"
      } else if (compared == "different") {
        "differs"
      } else if (file.exists(file.path(functions, variant))) {
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
