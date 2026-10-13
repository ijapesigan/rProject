.AIType <- function(path,
                    project) {
  manuscripts <- list.files(
    path = file.path(path, ".setup", "latex"),
    pattern = "-manuscript.*\\.Rtex$"
  )
  type <- c(
    manuscript = length(manuscripts) > 0L ||
      grepl(pattern = "^man", x = project),
    simulation = dir.exists(file.path(path, ".sim")),
    library = grepl(pattern = "^lib-", x = project),
    talk = grepl(pattern = "^talks", x = project),
    container = grepl(pattern = "^docker-", x = project)
  )
  type <- names(type)[type]
  if (length(type) == 0L) {
    type <- "package"
  }
  type
}
