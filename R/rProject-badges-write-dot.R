.BadgesWrite <- function(path) {
  # rewrites the badge block of README.md; a README without the two marker
  # lines, or a project without badges, stays as it is
  readme <- file.path(
    path,
    "README.md"
  )
  written <- FALSE
  if (file.exists(readme)) {
    lines <- readLines(
      con = readme,
      warn = FALSE
    )
    start <- which(x = trimws(x = lines) == "<!-- badges: start -->")
    end <- which(x = trimws(x = lines) == "<!-- badges: end -->")
    badges <- Badges(path = path)
    if (
      length(x = start) == 1 &&
        length(x = end) == 1 &&
        start < end &&
        length(x = badges) > 0
    ) {
      # a badge written by hand stays (CRAN status, codecov, the dynamic Pages
      # workflow, which has no file); the ones generated here, and blank lines,
      # are replaced
      # whole badges, since pandoc wraps a long badge over lines
      old <- paste(
        lines[seq(from = start, to = end)[-c(1, end - start + 1)]],
        collapse = " "
      )
      found <- regmatches(
        x = old,
        m = gregexpr(
          pattern = "\\[!\\[[^]]*\\]\\([^)]*\\)\\]\\([^)]*\\)",
          text = old
        )
      )[[1]]
      kept <- found[
        !grepl(
          pattern = "/actions/workflows/[^/]+\\.ya?ml/|doi\\.org/",
          x = found
        )
      ]
      is_doi <- grepl(pattern = "^\\[!\\[DOI\\]", x = badges)
      writeLines(
        text = c(
          lines[seq_len(length.out = start)],
          badges[is_doi],
          kept,
          badges[!is_doi],
          lines[seq(from = end, to = length(x = lines))]
        ),
        con = readme
      )
      written <- TRUE
    }
  }
  written
}
