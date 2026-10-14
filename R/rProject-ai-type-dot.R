.AIType <- function(path,
                    project) {
  manuscripts <- list.files(
    path = file.path(path, ".setup", "latex"),
    pattern = "-manuscript.*\\.Rtex$"
  )
  # every project has the template's .sim/make.sh (a SLURM job for
  # make all); a simulation has .sim/README.md, which describes it (the
  # template must not ship one)
  # cran-* folders: project.R names the package, not the folder
  folder <- basename(normalizePath(path, mustWork = FALSE))
  type <- c(
    manuscript = length(manuscripts) > 0L ||
      grepl(pattern = "^man", x = project),
    simulation = file.exists(file.path(path, ".sim", "README.md")),
    package = grepl(pattern = "^cran-", x = folder),
    cran = grepl(pattern = "^cran-", x = folder),
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
