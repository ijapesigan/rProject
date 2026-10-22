.TemplateTypeGuess <- function(path,
                               type = NULL) {
  # the template type: the type line in project.R, or else the AI() types
  # mapped to a template type (type: AI() types, guessed when NULL)
  template <- .TemplateType(path = path)
  if (is.null(template)) {
    if (is.null(type)) {
      project <- .TemplateSettings(path = path)$project
      type <- .AIType(
        path = path,
        project = ifelse(is.null(project), basename(path), project[1])
      )
    }
    map <- c(
      container = "docker",
      library = "lib",
      talk = "talk",
      manuscript = "man",
      package = "cran",
      cran = "cran"
    )
    template <- c(map[intersect(names(map), type)], "cran")[[1]]
  }
  template
}
