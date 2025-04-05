#' Data Process - `data/z.rda`
#'
DataProcessZ <- function() {
  rproj <- rprojroot::is_rstudio_project
  data_dir <- rproj$find_file(
    "data"
  )
  dir.create(
    path = data_dir,
    showWarnings = FALSE,
    recursive = TRUE
  )
  set.seed(42)
  z <- stats::rnorm(
    n = 100
  )
  save(
    z,
    file = file.path(
      data_dir,
      "z.rda"
    ),
    compress = FALSE
  )
}
DataProcessZ()
rm(DataProcessZ)
