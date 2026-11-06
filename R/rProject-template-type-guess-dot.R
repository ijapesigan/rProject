.TemplateTypeGuess <- function(path,
                               type = NULL) {
  # the template type: the type line in project.R, or else the AI() types
  # mapped to a template type (type: AI() types, guessed when NULL)
  template <- .TemplateType(path = path)
  if (is.null(x = template)) {
    if (is.null(x = type)) {
      project <- .TemplateSettings(path = path)$project
      type <- .AIType(
        path = path,
        project = ifelse(
          test = is.null(x = project),
          yes = basename(path = path),
          no = project[1]
        )
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
    template <- c(map[intersect(x = names(x = map), y = type)], "cran")[[1]]
  }
  template
}
