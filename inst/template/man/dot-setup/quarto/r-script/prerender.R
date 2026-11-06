# rprojroot
root <- rprojroot::is_rstudio_project

# package

# load functions
source(
  file = root$find_file(
    ".setup",
    "load",
    "load.R"
  )
)
Load(root)

# load data
x <- list.files(
  path = root$find_file(
    "data"
  ),
  pattern = "\\.rda$",
  full.names = TRUE,
  all.files = TRUE,
  recursive = TRUE
)
x <- c(
  x,
  list.files(
    path = root$find_file(
      ".data-dependencies"
    ),
    pattern = "\\.rda$",
    full.names = TRUE,
    all.files = TRUE,
    recursive = TRUE
  )
)
if (length(x = x) > 0) {
  for (i in seq_along(along.with = x)) {
    load(file = x[i])
  }
  rm(i)
}
rm(x)
