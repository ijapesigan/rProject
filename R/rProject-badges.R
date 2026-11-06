#' README Badges
#'
#' Returns a Markdown badge for the project's DOI and for each workflow in
#' `.github/workflows`. `ReadMe()` writes them between the
#' `<!-- badges: start -->` and `<!-- badges: end -->` lines of `README.md`,
#' and keeps any other badge there, such as CRAN status. The DOI is the first
#' `doi` in `inst/CITATION`; the placeholder `10.0000/0000000000` has no badge.
#' The r-hub review tiers (3 and 4) are labeled, because `continue-on-error`
#' keeps their badges green. Tier 5, run by hand, has no badge.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @return Returns a character vector of Markdown badges.
#'   It is empty when the project has no DOI, and no workflows or public
#'   repository.
#' @examples
#' \dontrun{
#' Badges(path = getwd())
#' }
#' @export
Badges <- function(path) {
  public <- .PublicRepo(path = path)
  files <- list.files(
    path = file.path(
      path,
      ".github",
      "workflows"
    ),
    pattern = "\\.ya?ml$",
    full.names = TRUE
  )
  files <- files[!grepl(pattern = "rhub-5-", x = basename(path = files))]
  if (is.na(x = public) || length(x = files) == 0) {
    badges <- character(length = 0)
  } else {
    # the main build first, then in file order
    first <- grepl(pattern = "^make", x = basename(path = files))
    files <- c(files[first], files[!first])
    badges <- vapply(
      X = files,
      FUN = function(file) {
        lines <- readLines(
          con = file,
          warn = FALSE
        )
        name <- sub(
          pattern = "^name:[[:space:]]*",
          replacement = "",
          x = grep(pattern = "^name:", x = lines, value = TRUE)[1]
        )
        name <- gsub(pattern = "[\"']", replacement = "", x = name)
        if (is.na(x = name)) {
          name <- basename(path = file)
        }
        if (grepl(pattern = "rhub-[34]-", x = basename(path = file))) {
          name <- paste0(name, ", review only")
        }
        base <- paste0(
          "https://github.com/",
          public,
          "/actions/workflows/",
          basename(path = file)
        )
        paste0("[![", name, "](", base, "/badge.svg)](", base, ")")
      },
      FUN.VALUE = character(length = 1),
      USE.NAMES = FALSE
    )
  }
  c(
    .BadgeDoi(path = path),
    badges
  )
}
