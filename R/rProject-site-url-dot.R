.SiteUrl <- function(path) {
  # owner/repository to the GitHub Pages address; NULL without a public copy,
  # so pkgdown::build_site() keeps what _pkgdown.yml says
  public <- .PublicRepo(path = path)
  url <- NULL
  if (!is.na(x = public)) {
    parts <- strsplit(x = public, split = "/", fixed = TRUE)[[1]]
    url <- paste0("https://", parts[1], ".github.io/", parts[2], "/")
  }
  url
}
